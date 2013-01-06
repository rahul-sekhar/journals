require 'spec_helper'

describe StudentObservation do
  let(:student_observation){ build(:student_observation) }

  it "is valid with valid attributes" do
    student_observation.should be_valid
  end

  it "is invalid without a post" do
    student_observation.post = nil
    student_observation.should be_invalid
  end

  it "is invalid without a student" do
    student_observation.student = nil
    student_observation.should be_invalid
  end

  it "is invalid without content" do
    student_observation.content = nil
    student_observation.should be_invalid
  end

  it "is invalid when the content has just spaces" do
    student_observation.content = "  "
    student_observation.should be_invalid
  end
end