require 'spec_helper'

describe Tag do
  let(:tag){ build(:tag) }

  it "is valid with valid attributes" do
    tag.should be_valid
  end

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

    it "has a maximum length of 60 characters" do
      tag.name = "a" * 60
      tag.should be_valid
      tag.name = "a" * 61
      tag.should be_invalid
    end

    it "is trimmed of extra whitespace" do
      tag.name = "Blah "
      tag.save
      tag.reload.name.should == "Blah"
    end
  end

  describe "##name_is" do
    before { @existing_tag = create(:tag, name: "Some Tag") }
    
    it "returns nil no matching tags exist" do
      returned_tag = Tag.name_is("Other Tag")
      returned_tag.should be_nil
    end

    it "returns a matching tag case insensitively" do
      returned_tag = Tag.name_is("some TAG")
      returned_tag.should eq(@existing_tag)
    end
  end
  
end