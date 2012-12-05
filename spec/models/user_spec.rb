require 'spec_helper'

describe User do
  let(:user){ build(:user_rahul) }

  it "is valid with valid attributes" do
    user.should be_valid
  end

  it "is invalid without a username" do
    user.username = nil
    user.should be_invalid
  end

  it "cannot be saved without a password" do
    user.password = nil
    user.should be_invalid
  end

  it "sets the password hash and salt when saved" do
    user.save
    user.password_salt.should be_present
    user.password_hash.should be_present
  end

  describe "authenticate" do
    let(:other_user){ build(:user_shalu) }

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
end