require 'spec_helper'

describe StudentMilestone do
  let(:student_milestone){ build(:student_milestone) }

  it "is valid with valid attributes" do
    student_milestone.should be_valid
  end

  it "is invalid without a milestone" do
    student_milestone.milestone = nil
    student_milestone.should be_invalid
  end

  it "is invalid without a student" do
    student_milestone.student = nil
    student_milestone.should be_invalid
  end

  it "must be unique for a student and milestone" do
    create(:student_milestone, student: student_milestone.student, milestone: student_milestone.milestone)
    student_milestone.should be_invalid
  end

  describe "self destruction" do
    before do
      student_milestone.status = 1
      student_milestone.comments = "Some comments"
      student_milestone.save!
    end

    it "is not destroyed if comments are present" do
      student_milestone.status = 0
      student_milestone.save!
      student_milestone.should_not be_destroyed
    end

    it "is not destroyed if the status is not 0" do
      student_milestone.comments = nil
      student_milestone.save!
      student_milestone.should_not be_destroyed
    end

    it "is destroyed if comments are not present and the status is 0" do
      student_milestone.status = 0
      student_milestone.comments = nil
      student_milestone.save!
      student_milestone.should be_destroyed
    end
  end

  describe "status" do
    it "is required" do
      student_milestone.status = nil
      student_milestone.should be_invalid
    end

    it "must be an integer" do
      student_milestone.status = 'asd'
      student_milestone.should be_invalid
    end

    it 'cannot be less than 0' do
      student_milestone.status = -1
      student_milestone.should be_invalid
      student_milestone.status = 0
      student_milestone.should be_valid
    end

    it 'cannot be more than 3' do
      student_milestone.status = 4
      student_milestone.should be_invalid
      student_milestone.status = 3
      student_milestone.should be_valid
    end
  end

  describe "#from_subject" do
    it "loads student milestones from a particular subject" do
      sub1 = create(:subject)
      sub2 = create(:subject)
      sub3 = create(:subject)
      sm1 = create(:student_milestone, milestone: create(:milestone, strand: sub1.add_strand('Strand 1')))
      sm2 = create(:student_milestone, milestone: create(:milestone, strand: sub2.add_strand('Strand 2')))
      sm3 = create(:student_milestone, milestone: create(:milestone, strand: sub1.strands.first))
      sm4 = create(:student_milestone, milestone: create(:milestone, strand: sub2.add_strand('Strand 3')))
      sm5 = create(:student_milestone, milestone: create(:milestone, strand: sub1.add_strand('Strand 4').add_strand('Strand 5')))

      StudentMilestone.from_subject(sub1).should match_array [sm1, sm3, sm5]
      StudentMilestone.from_subject(sub2).should match_array [sm2, sm4]
      StudentMilestone.from_subject(sub3).should be_empty
    end
  end
end