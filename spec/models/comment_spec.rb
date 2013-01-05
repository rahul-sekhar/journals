require 'spec_helper'

describe Comment do
  let(:comment){ build(:comment) }

  it "is valid with valid attributes" do
    comment.should be_valid
  end

  it "is invalid without a post" do
    comment.post = nil
    comment.should be_invalid
  end

  it "is invalid without a user" do
    comment.user = nil
    comment.should be_invalid
  end

  it "is invalid without content" do
    comment.content = nil
    comment.should be_invalid
  end

  describe "#formatted_created_at" do
    it "returns a formatted version of the created date" do
      comment.created_at = Date.new(2012, 1, 1)
      comment.formatted_created_at.should == "1st January 2012"
    end
  end

  describe "#author_name" do
    it "returns the associated users name" do
      comment.user.stub(:name).and_return("Some Name")
      comment.author_name.should eq("Some Name")
    end
  end

  describe "#author_profile" do
    it "returns the associated users profile" do
      comment.author_profile.should eq(comment.user.profile)
    end
  end
end