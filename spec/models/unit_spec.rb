require 'spec_helper'

describe Unit do
  let(:unit){ build(:unit) }

  it "is valid with valid attributes" do
    unit.should be_valid
  end

  it "is invalid without a subject" do
    unit.subject = nil
    unit.should be_invalid
  end

  it "is invalid without a student" do
    unit.student = nil
    unit.should be_invalid
  end

  describe "name" do
    it "is required" do
      unit.name = nil
      unit.should be_invalid
    end

    it "has a maximum length of 80 characters" do
      unit.name = "a" * 80
      unit.should be_valid
      unit.name = "a" * 81
      unit.should be_invalid
    end

    it "is trimmed of extra whitespace" do
      unit.name = "Blah "
      unit.save!
      unit.reload.name.should == "Blah"
    end
  end
end