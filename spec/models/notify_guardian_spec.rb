require 'spec_helper'

describe NotifyGuardian, :c do
  describe '##notify_all' do
    it 'notifies each guardian' do
      guardian1 = FactoryGirl.create(:guardian)
      guardian2 = FactoryGirl.create(:guardian)

      expect(NotifyGuardian).to receive(:new).with(guardian1)
      expect(NotifyGuardian).to receive(:new).with(guardian2)

      NotifyGuardian.notify_all
    end
  end

  describe 'notifying a guardian' do
    let!(:student1){ FactoryGirl.create(:student) }
    let!(:student2){ FactoryGirl.create(:student) }
    let!(:student3){ FactoryGirl.create(:student, guardians: [FactoryGirl.create(:guardian)]) }

    let!(:guardian){ FactoryGirl.create(:guardian, students: [student1, student2]) }

    describe 'posts' do
      let(:post1){ FactoryGirl.create(:post, students: [student1]) }
      let(:post2){ FactoryGirl.create(:post, students: [student1], visible_to_guardians: true) }
      let(:post3){ FactoryGirl.create(:post, students: [student1], visible_to_guardians: true) }
      let(:post4){ FactoryGirl.create(:post, students: [student3], visible_to_guardians: true) }
      let(:post5){ FactoryGirl.create(:post, students: [student1, student2, student3], visible_to_guardians: true) }
      let(:post6){ FactoryGirl.create(:post, students: [student1], author: guardian, visible_to_guardians: true) }

      before do
        post3

        guardian.last_notified = Time.now
        guardian.save!
      end

      describe 'with posts created for both students' do
        before do
          post1
          post2
          post3.touch
          post4
          post5
          post6

          allow(Time).to receive(:now){ DateTime.new(2014, 5, 5) }
          @notifications = NotifyGuardian.new(guardian)
        end

        it 'sets notifications for both students' do
          expect(@notifications.students.count).to eq 2
          expect(@notifications.students.map{ |x| x[:student] }).to match_array [student1, student2]
        end

        it 'sets the post notifications for student1' do
          notifications = @notifications.students.find{ |x| x[:student] == student1 }
          expect(notifications[:posts]).to match_array [post2, post5]
        end

        it 'sets the post notifications for student2' do
          notifications = @notifications.students.find{ |x| x[:student] == student2 }
          expect(notifications[:posts]).to match_array [post5]
        end

        it 'sets last notified' do
          expect(guardian.reload.last_notified).to eq DateTime.new(2014, 5, 5)
        end
      end

      describe 'with posts created for one student' do
        before do
          post2

          allow(Time).to receive(:now){ DateTime.new(2014, 5, 5) }
          @notifications = NotifyGuardian.new(guardian)
        end

        it 'sets notifications for one student' do
          expect(@notifications.students.count).to eq 1
          expect(@notifications.students.map{ |x| x[:student] }).to match_array [student1]
        end

        it 'sets the post notifications for student1' do
          notifications = @notifications.students.first
          expect(notifications[:posts]).to match_array [post2]
        end

        it 'sets last notified' do
          expect(guardian.reload.last_notified).to eq DateTime.new(2014, 5, 5)
        end
      end

      describe 'with posts created for no students' do
        before do
          allow(Time).to receive(:now){ DateTime.new(2014, 5, 5) }
          @notifications = NotifyGuardian.new(guardian)
        end

        it 'sets notifications for no students' do
          expect(@notifications.students).to be_empty
        end

        it 'sets last notified' do
          expect(guardian.reload.last_notified).to eq DateTime.new(2014, 5, 5)
        end
      end
    end

    describe 'subjects' do
      let!(:subject1){ FactoryGirl.create(:subject) }
      let!(:subject2){ FactoryGirl.create(:subject) }
      let!(:subject3){ FactoryGirl.create(:subject) }

      let!(:unit1){ FactoryGirl.create(:unit, subject: subject1, student: student1) }
      let!(:unit3){ FactoryGirl.create(:unit, subject: subject1, student: student3) }
      let!(:unit4){ FactoryGirl.create(:unit, subject: subject1, student: student1) }
      let!(:unit5){ FactoryGirl.create(:unit, subject: subject1, student: student1) }

      let!(:strand1){ FactoryGirl.create(:strand, subject: subject1) }
      let!(:strand2){ FactoryGirl.create(:strand, subject: subject2) }
      let!(:milestone1){ FactoryGirl.create(:milestone, strand: strand1) }
      let!(:milestone2){ FactoryGirl.create(:milestone, strand: strand2) }

      let!(:student_milestone1){ FactoryGirl.create(:student_milestone, milestone: milestone1, student: student2) }
      let!(:student_milestone2){ FactoryGirl.create(:student_milestone, milestone: milestone2, student: student2) }
      let!(:student_milestone3){ FactoryGirl.create(:student_milestone, milestone: milestone1, student: student3) }

      before do
        guardian.last_notified = Time.now
        guardian.save!
      end

      describe 'with subjects updated for both students' do
        before do
          unit1.touch
          FactoryGirl.create(:unit, subject: subject2, student: student1)
          unit3.touch
          unit5.touch
          student_milestone1.touch
          student_milestone3.touch

          allow(Time).to receive(:now){ DateTime.new(2014, 5, 5) }
          @notifications = NotifyGuardian.new(guardian)
        end

        it 'sets notifications for both students' do
          expect(@notifications.students.count).to eq 2
          expect(@notifications.students.map{ |x| x[:student] }).to match_array [student1, student2]
        end

        it 'sets the subject notifications for student1' do
          notifications = @notifications.students.find{ |x| x[:student] == student1 }
          expect(notifications[:subjects]).to match_array [subject1, subject2]
        end

        it 'sets the subject notifications for student2' do
          notifications = @notifications.students.find{ |x| x[:student] == student2 }
          expect(notifications[:subjects]).to match_array [subject1]
        end

        it 'sets last notified' do
          expect(guardian.reload.last_notified).to eq DateTime.new(2014, 5, 5)
        end
      end

      describe 'with subjects updated for one student' do
        before do
          FactoryGirl.create(:student_milestone, milestone: milestone2, student: student1)

          allow(Time).to receive(:now){ DateTime.new(2014, 5, 5) }
          @notifications = NotifyGuardian.new(guardian)
        end

        it 'sets notifications for one student' do
          expect(@notifications.students.count).to eq 1
          expect(@notifications.students.map{ |x| x[:student] }).to match_array [student1]
        end

        it 'sets the subject notifications for student1' do
          notifications = @notifications.students.first
          expect(notifications[:subjects]).to match_array [subject2]
        end

        it 'sets last notified' do
          expect(guardian.reload.last_notified).to eq DateTime.new(2014, 5, 5)
        end
      end

      describe 'with subjects updated for no students' do
        before do
          allow(Time).to receive(:now){ DateTime.new(2014, 5, 5) }
          @notifications = NotifyGuardian.new(guardian)
        end

        it 'sets notifications for no students' do
          expect(@notifications.students).to be_empty
        end

        it 'sets last notified' do
          expect(guardian.reload.last_notified).to eq DateTime.new(2014, 5, 5)
        end
      end
    end
  end
end