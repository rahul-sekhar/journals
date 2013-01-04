require 'spec_helper'

describe User do
  let(:teacher){ create(:teacher, email: "test@mail.com", password: "test-pass" ) }
  let(:user){ teacher.user }
  let(:student){ create(:student ) }
  let(:student_user){ student.user }

  it "is valid with valid attributes" do
    user.should be_valid
  end

  describe "email" do
    it "is required" do
      user.email = nil
      user.should be_invalid
    end

    it "is invalid for an invalid email format" do
      %w[a@b blah @a.com].each do |email|
        user.email = email
        user.should be_invalid, email
      end
    end

    it "is valid for a valid email format" do
      %w[a@b.c test.email@server.co.in].each do |email|
        user.email = email
        user.should be_valid, email
      end
    end

    it "must be case insensitively unique" do
      create(:teacher, email: "test1@mail.com")
      user.email = "Test1@Mail.com"
      user.should be_invalid
    end
  end

  describe "password" do
    it "is required" do
      user.password = nil
      user.should be_invalid
    end

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
    user.password_salt.should be_present
    user.password_hash.should be_present
  end
  
  describe "authenticate" do
    let(:other_user){ create(:teacher, email: "other_test@mail.com", password: "other-pass").user }
    before{ user.save }

    it "returns the matched user when given a valid username and password" do
      other_user
      User.authenticate("test@mail.com", "test-pass").should == user
      User.authenticate("other_test@mail.com", "other-pass").should == other_user
    end

    it "returns nil with a valid username but invalid password" do
      User.authenticate("test@mail.com", "other-pass").should be_nil
    end

    it "returns nil with an invalid username" do
      User.authenticate("test1@mail.com", "test-pass").should be_nil
    end

    it "returns nil with a nil password" do
      User.authenticate("test1@mail.com", nil).should be_nil
    end
  end

  it "does not reset the password when it is blank" do
    user.password = ""
    user.save
    User.authenticate("test@mail.com", "test-pass").should == user
  end

  describe "on destruction" do
    it "destroys its associated profile" do
      user.save
      expect { user.destroy }.to change { Teacher.count }.by(-1)
    end

    it "destroys any posts" do
      user.save!
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

  describe "#is_teacher?" do
    it "returns true if the profile is a teacher" do
      user.is_teacher?.should == true
    end

    it "returns false if the profile is a student" do
      student_user.is_teacher?.should == false
    end
  end

  describe "#is_student?" do
    it "returns true if the profile is a student" do
      student_user.is_student?.should == true
    end

    it "returns false if the profile is a teacher" do
      user.is_student?.should == false
    end
  end
end