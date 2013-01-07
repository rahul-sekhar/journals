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

  it "is invalid without an author" do
    comment.author = nil
    comment.should be_invalid
  end

  it "is invalid without content" do
    comment.content = nil
    comment.should be_invalid
  end

  it "is invalid when the content has just spaces" do
    comment.content = "  "
    comment.should be_invalid
  end

  describe "#formatted_created_at" do
    it "returns a formatted version of the created date" do
      comment.created_at = Date.new(2012, 1, 1)
      comment.formatted_created_at.should == "1st January 2012"
    end
  end
end