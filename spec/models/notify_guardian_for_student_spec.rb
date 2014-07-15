require 'spec_helper'

describe NotifyGuardianForStudent do
  let!(:student1){ FactoryGirl.create(:student) }
  let!(:student2){ FactoryGirl.create(:student) }
  let!(:guardian){ FactoryGirl.create(:guardian, students: [student1, student2]) }

  subject{ NotifyGuardianForStudent.new(guardian, student1) }

  describe 'posts' do
    subject{ NotifyGuardianForStudent.new(guardian, student1).posts }

    let(:post){ FactoryGirl.create(:post) }

    it { should be_empty }

    describe 'invisible to guardians' do
      describe 'tagged with the student' do
        let(:post){ FactoryGirl.create(:post, students: [student1]) }

        it { should be_empty }
      end
    end

    describe 'visible to guardians' do
      describe 'tagged with the student' do
        let(:post){ FactoryGirl.create(:post, visible_to_guardians: true, students: [student1]) }

        it { should eq [post] }

        describe 'authored by himself' do
          let(:post){ FactoryGirl.create(:post, author: guardian, visible_to_guardians: true, students: [student1]) }

          it { should be_empty }
        end

        describe 'created before last notified' do
          before do
            post
            guardian.last_notified = Time.now
            guardian.save!
          end

          it { should be_empty }

          describe 'updated after' do
            before{ post.touch }

            it { should be_empty }
          end
        end
      end

      describe 'tagged with another student' do
        let(:post){ FactoryGirl.create(:post, visible_to_guardians: true, students: [student1]) }

        it { should be_empty }
      end
    end

    describe 'with multiple posts' do
      let!(:post1){ FactoryGirl.create(:post) }
      let!(:post2){ FactoryGirl.create(:post, visible_to_guardians: true, students: [student1]) }
      let!(:post3){ FactoryGirl.create(:post, author: guardian, visible_to_guardians: true, students: [student1]) }
      let!(:post4){ FactoryGirl.create(:post, visible_to_guardians: true, students: [student1, student2]) }

      it { should eq [post4, post2] }
    end
  end

  describe 'comments' do
    subject{ NotifyGuardianForStudent.new(guardian, student1).comments }

    let(:invisible_post){ FactoryGirl.create(:post, students: [student1]) }
    let(:visible_post){ FactoryGirl.create(:post, students: [student1], visible_to_guardians: true) }
    let(:own_post){ FactoryGirl.create(:post, students: [student1], author: guardian) }
    let(:other_student_post){ FactoryGirl.create(:post, students: [student2], visible_to_guardians: true) }

    it { should be_empty }

    describe 'on invisible post' do
      let!(:comment){ FactoryGirl.create(:comment, post: invisible_post) }

      it { should be_empty }
    end

    describe 'on other student post' do
      let!(:comment){ FactoryGirl.create(:comment, post: other_student_post) }

      it { should be_empty }
    end

    describe 'on visible post' do
      let!(:comment){ FactoryGirl.create(:comment, post: visible_post) }

      it { should eq [comment] }

      describe 'created before last notified' do
        before do
          guardian.last_notified = Time.now
          guardian.save!
        end

        it { should be_empty }

        describe 'updated after' do
          before{ comment.touch }

          it { should be_empty }
        end
      end

      describe 'multiple comments' do
        let!(:comment2){ FactoryGirl.create(:comment, post: visible_post) }

        it { should eq [comment2, comment] }
      end

      describe 'comment by self' do
        let!(:comment){ FactoryGirl.create(:comment, post: visible_post, author: guardian) }

        it { should be_empty }
      end

      describe 'comment by another guardian' do
        let!(:comment){ FactoryGirl.create(:comment, post: visible_post, author: FactoryGirl.create(:guardian)) }

        it { should eq [comment] }
      end
    end

    describe 'on own post' do
      let!(:comment){ FactoryGirl.create(:comment, post: own_post) }

      it { should eq [comment] }
    end

    describe 'multiple comments' do
      let!(:post2){ FactoryGirl.create(:post, students: [student1], visible_to_guardians: true) }
      let!(:comment1){ FactoryGirl.create(:comment, post: visible_post) }
      let!(:comment2){ FactoryGirl.create(:comment, post: post2) }
      let!(:comment3){ FactoryGirl.create(:comment, post: invisible_post) }
      let!(:comment4){ FactoryGirl.create(:comment, post: visible_post) }
      let!(:comment5){ FactoryGirl.create(:comment, post: own_post) }
      let!(:comment6){ FactoryGirl.create(:comment, post: other_student_post) }

      it { should eq [comment5, comment4, comment2, comment1] }
    end
  end

  describe 'subjects' do
    subject{ NotifyGuardianForStudent.new(guardian, student1).subjects }

    let!(:subject1){ FactoryGirl.create(:subject) }
    let!(:subject2){ FactoryGirl.create(:subject) }
    let!(:strand1){ FactoryGirl.create(:strand, subject: subject1) }
    let!(:strand2){ FactoryGirl.create(:strand, subject: subject2) }
    let!(:milestone1){ FactoryGirl.create(:milestone, strand: strand1) }
    let!(:milestone2){ FactoryGirl.create(:milestone, strand: strand2) }
    let!(:milestone3){ FactoryGirl.create(:milestone, strand: strand2) }

    it { should be_empty }

    describe 'unit created' do
      let!(:unit){ FactoryGirl.create(:unit, subject: subject1, student: student1) }

      it { should eq [subject1] }

      describe 'after last notified' do
        before do
          guardian.last_notified = Time.now
          guardian.save!
        end

        it { should be_empty }

        describe 'when updated' do
          before{ unit.touch }

          it { should eq [subject1] }
        end
      end

      describe 'multiple units' do
        let!(:unit2){ FactoryGirl.create(:unit, subject: subject1, student: student1) }
        let!(:unit3){ FactoryGirl.create(:unit, subject: subject1, student: student1) }

        it { should eq [subject1] }
      end
    end

    describe 'unit created for a different student' do
      let!(:unit){ FactoryGirl.create(:unit, subject: subject1, student: student2) }

      it { should be_empty }
    end

    describe 'milestone created' do
      let!(:student_milestone){ FactoryGirl.create(:student_milestone, milestone: milestone2, student: student1) }

      it { should eq [subject2] }

      describe 'after last notified' do
        before do
          guardian.last_notified = Time.now
          guardian.save!
        end

        it { should be_empty }

        describe 'when updated' do
          before{ student_milestone.touch }

          it { should eq [subject2] }
        end
      end

      describe 'multiple milestones' do
        let!(:student_milestone2){ FactoryGirl.create(:student_milestone, milestone: milestone3, student: student1) }

        it { should eq [subject2] }
      end
    end

    describe 'milestone created for a different student' do
      let!(:student_milestone){ FactoryGirl.create(:student_milestone, milestone: milestone2, student: student2) }

      it { should be_empty }
    end

    describe 'multiple subjects' do
      let!(:unit1){ FactoryGirl.create(:unit, subject: subject1, student: student1) }
      let!(:unit2){ FactoryGirl.create(:unit, subject: subject1, student: student1) }
      let!(:student_milestone1){ FactoryGirl.create(:student_milestone, milestone: milestone1, student: student1) }
      let!(:student_milestone2){ FactoryGirl.create(:student_milestone, milestone: milestone2, student: student1) }
      let!(:student_milestone3){ FactoryGirl.create(:student_milestone, milestone: milestone3, student: student1) }

      it { should match_array [subject1, subject2] }
    end
  end
end