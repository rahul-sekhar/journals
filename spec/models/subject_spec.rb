require 'spec_helper'

describe Subject, :focus do
  let(:subject){ build(:subject) }

  it "is valid with valid attributes" do
    subject.should be_valid
  end

  describe "name" do
    it "is required" do
      subject.name = nil
      subject.should be_invalid
    end

    it "must be unique" do
      create(:subject, name: "some-subject")
      subject.name = "Some-Subject"
      subject.should be_invalid
    end

    it "must be unique with whitespace" do
      create(:subject, name: "some-subject")
      subject.name = "Some-Subject "
      subject.should be_invalid
    end

    it "has a maximum length of 50 characters" do
      subject.name = "a" * 50
      subject.should be_valid
      subject.name = "a" * 51
      subject.should be_invalid
    end

    it "is trimmed of extra whitespace" do
      subject.name = "Blah "
      subject.save
      subject.reload.name.should == "Blah"
    end
  end
end