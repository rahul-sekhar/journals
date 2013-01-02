require 'spec_helper'

describe Post do
  let(:post){ build(:post) }

  it "is valid with valid attributes" do
    post.should be_valid
  end

  it "is invalid without a title" do
    post.title = nil
    post.should be_invalid
  end

  it "is invalid without a user (author)" do
    post.user = nil
    post.should be_invalid
  end

  describe "#formatted_created_at" do
    it "returns a formatted version of the created date" do
      post.created_at = Date.new(2009, 2, 3)
      post.formatted_created_at.should == "3rd February 2009"
    end
  end

  describe "#author" do
    it "returns the associated users name" do
      post.user.stub(:name).and_return("Some Name")
      post.author.should eq("Some Name")
    end
  end
end