require 'spec_helper'

describe SubjectTeacher do
  let(:subject_teacher){ build(:subject_teacher) }

  it "is valid with valid attributes" do
    subject_teacher.should be_valid
  end

  it "requires a subject" do
    subject_teacher.subject = nil
    subject_teacher.should be_invalid
  end

  it "requires a teacher" do
    subject_teacher.teacher = nil
    subject_teacher.should be_invalid
  end

  describe "uniqueness" do
    before { subject_teacher.save! }
    let(:duplicate) { build(:subject_teacher, subject: subject_teacher.subject, teacher: subject_teacher.teacher) }

    it "is invalid with the same subject and teacher" do
      duplicate.should be_invalid
    end

    it "is valid with a different teacher" do
      duplicate.teacher = create(:teacher)
      duplicate.should be_valid
    end

    it "is valid with a different subject" do
      duplicate.subject = create(:subject)
      duplicate.should be_valid
    end
  end
end