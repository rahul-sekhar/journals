require 'spec_helper'

describe Group do
  let(:group){ build(:group) }
  let(:object_class){ Group }

  it "is valid with valid attributes" do
    group.should be_valid
  end

  it_should_behave_like "a taggable object"

  describe "name" do
    it "is required" do
      group.name = nil
      group.should be_invalid
    end
    
    it "must be unique" do
      create(:group, name: "some-group")
      group.name = "Some-Group"
      group.should be_invalid
    end

    it "must be unique with whitespace" do
      create(:group, name: "some-group")
      group.name = "Some-Group "
      group.should be_invalid
    end

    it "has a maximum length of 50 characters" do
      group.name = "a" * 50
      group.should be_valid
      group.name = "a" * 51
      group.should be_invalid
    end

    it "is trimmed of extra whitespace" do
      group.name = "Blah "
      group.save
      group.reload.name.should == "Blah"
    end
  end
end