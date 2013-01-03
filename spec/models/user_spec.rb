require 'spec_helper'

describe User do
  let(:user){ build(:user, username: "rahul", password: "test-pass") }

  it "is valid with valid attributes" do
    user.should be_valid
  end

  it "is invalid without a username" do
    user.username = nil
    user.should be_invalid
  end

  describe "username" do
    it "is valid with letters, numbers and underscores" do
      user.username = "1_2asfzdRc_a2"
      user.should be_valid
    end

    it "is invalid with spaces" do
      user.username = "as bc"
      user.should be_invalid
    end

    it "is invalid with symbols" do
      user.username = "asd#"
      user.should be_invalid
    end

    it "is invalid with dots" do
      user.username = "asd."
      user.should be_invalid
    end

    it "is invalid with dashes" do
      user.username = "asd-"
      user.should be_invalid
    end

    it "must be unique" do
      create(:user, username: "blah")
      user.username = "blah"
      user.should be_invalid
    end
  end

  it "cannot be saved without a password" do
    user.password = nil
    user.should be_invalid
  end

  describe "password" do
    it "must have at least four characters" do
      user.password = "pas"
      user.should be_invalid
    end

    it "cannot have spaces" do
      user.password = "blah blah"
      user.should be_invalid
    end
  end

  it "sets the password hash and salt when saved" do
    user.save
    user.password_salt.should be_present
    user.password_hash.should be_present
  end

  it "requires a profile" do
    user.profile = nil
    user.should be_invalid
  end

  describe "authenticate" do
    let(:other_user){ build(:user, username: "shalu", password: "other-pass") }

    before { user.save }

    it "returns the matched user when given a valid username and password" do
      other_user.save
      User.authenticate("rahul", "test-pass").should == user
      User.authenticate("shalu", "other-pass").should == other_user
    end

    it "returns nil with a valid username but invalid password" do
      User.authenticate("rahul", "other-pass").should be_nil
    end

    it "returns nil with an invalid username" do
      User.authenticate("rahul1", "test-pass").should be_nil
    end

    it "returns nil with a nil password" do
      User.authenticate("rahul1", nil).should be_nil
    end
  end

  it "does not reset the password when it is blank" do
    user.save
    user.password = ""
    user.save
    User.authenticate("rahul", "test-pass").should == user
  end

  describe "on destruction" do
    before { user.save! }

    it "destroys its associated profile" do
      expect { user.destroy }.to change { Teacher.count }.by(-1)
    end

    it "destroys any posts" do
      create(:post, user_id: user.id)
      expect { user.destroy }.to change { Post.count }.by(-1)
    end
  end

  describe "#name" do
    it "returns the profile name" do
      user.profile.stub(:name).and_return("Name")
      user.name.should == "Name"
    end
  end
end