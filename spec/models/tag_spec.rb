require 'spec_helper'

describe Tag do
  let(:tag){ build(:tag) }
  let(:object_class){ Tag }

  it "is valid with valid attributes" do
    tag.should be_valid
  end

  it_should_behave_like "a taggable object"

  describe "name" do
    it "is required" do
      tag.name = nil
      tag.should be_invalid
    end
    
    it "must be unique" do
      create(:tag, name: "some-tag")
      tag.name = "Some-Tag"
      tag.should be_invalid
    end

    it "must be unique with whitespace" do
      create(:tag, name: "some-tag")
      tag.name = "Some-Tag "
      tag.should be_invalid
    end

    it "has a maximum length of 50 characters" do
      tag.name = "a" * 50
      tag.should be_valid
      tag.name = "a" * 51
      tag.should be_invalid
    end

    it "is trimmed of extra whitespace" do
      tag.name = "Blah "
      tag.save
      tag.reload.name.should == "Blah"
    end
  end
end