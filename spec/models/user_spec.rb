require 'spec_helper'

describe User do
  let(:user){ create(:teacher, email: "test@mail.com").user }

  it "is valid with valid attributes" do
    user.should be_valid
  end

  it "does not save without a profile" do
    expect{ build(:user).save }.to raise_exception
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

    it "cannot be more than 60 characters" do
      user = create(:teacher_with_user).user
      user.email = "a" * 51 + "@email.com"
      user.should be_invalid
    end
  end

  describe "#generate_password" do
    it "returns a ten letter password" do
      user.generate_password.length.should == 10
    end

    it "sets the user password to the generated one" do
      pass = user.generate_password
      user.save!
      User.authenticate("test@mail.com", pass).should == user
    end

    it "changes the password each time it is called" do
      old_pass = user.generate_password
      user.save!
      User.authenticate("test@mail.com", old_pass).should == user

      new_pass = user.generate_password
      user.save!
      User.authenticate("test@mail.com", old_pass).should be_nil
      User.authenticate("test@mail.com", new_pass).should == user
    end
  end

  describe "#is_active?" do
    it "returns false when initially created" do
      user.should_not be_active
    end

    it "returns true after a password is generated" do
      user.generate_password
      user.save!
      user.should be_active
    end
  end

  describe "#deactivate" do
    before do 
      user.generate_password
      user.save!
    end

    it "sets the password_hash to nil" do
      user.password_hash.should be_present
      user.deactivate
      user.reload.password_hash.should be_nil
    end

    it "disallows authentication" do
      user.set_password "pass"
      User.authenticate("test@mail.com", "pass").should eq(user)
      user.deactivate
      User.authenticate("test@mail.com", "pass").should be_nil
    end
  end

  describe "on initial creation" do
    it "sets the password salt" do
      user.password_salt.should be_present
    end

    it "does not set the password hash" do
      user.password_hash.should be_blank
    end

    it "should not be authenticatable" do
      User.authenticate("test@mail.com", "pass").should be_nil
      User.authenticate("test@mail.com", "").should be_nil
    end
  end

  describe "#new_password" do
    before do
      user.set_password "pass"
      user.current_password = "pass"
    end

    it "can be blank" do
      user.new_password = ""
      user.should be_valid
    end

    it "cannot be less than 4 characters" do
      user.new_password = "asdf"
      user.should be_valid
      user.new_password = "asd"
      user.should be_invalid
    end

    it "cannot have spaces" do
      user.new_password = "some pass"
      user.should be_invalid
    end

    it "can have letters, numbers and symbols" do
      user.new_password = "asf_1-%24#5s$"
      user.should be_valid
    end

    describe "changing the password" do
      it "does not change the password when nil" do
        user.new_password = nil
        user.save!
        User.authenticate("test@mail.com", "pass").should == user
      end

      it "does not change the password when blank" do
        user.new_password = " "
        user.save!
        User.authenticate("test@mail.com", "pass").should == user
      end

      it "changes the password when the password present" do
        user.new_password = "some-pass"
        user.save!
        User.authenticate("test@mail.com", "pass").should be_nil
        User.authenticate("test@mail.com", "some-pass").should == user
      end

      it "does not change the password when the current_password is empty" do
        user.new_password = "some-pass"
        user.current_password = nil
        user.should be_invalid
      end

      it "does not change the password when the current_password is wrong" do
        user.new_password = "some-pass"
        user.current_password = "wrongpass"
        user.should be_invalid
      end
    end
  end

  describe "#set_password" do
    it "sets the password to the passed value" do
      user.set_password("a_password")
      User.authenticate("test@mail.com", "a_password").should == user
    end
  end
  
  describe "authenticate" do
    context "with an inactive user" do
      before{ user }

      it "returns nil" do
        User.authenticate("test@mail.com", "").should be_nil
      end
    end
    
    context "with active users" do
      let(:other_user){ create(:teacher, email: "other_test@mail.com").user }
      
      before do
        user.set_password "test-pass"
        other_user.set_password "other-pass"
      end

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
  end

  context "when the profile is a teacher" do
    before{ user.profile = Teacher.new }

    specify "#is_teacher? returns true" do
      user.is_teacher?.should == true
    end

    specify "#is_student? returns false" do
      user.is_student?.should == false
    end

    specify "#is_guardian? returns false" do
      user.is_guardian?.should == false
    end
  end

  context "when the profile is a student" do
    before{ user.profile = Student.new }

    specify "#is_teacher? returns false" do
      user.is_teacher?.should == false
    end

    specify "#is_student? returns true" do
      user.is_student?.should == true
    end

    specify "#is_guardian? returns false" do
      user.is_guardian?.should == false
    end
  end

  context "when the profile is a guardian" do
    before{ user.profile = Guardian.new }

    specify "#is_teacher? returns false" do
      user.is_teacher?.should == false
    end

    specify "#is_student? returns false" do
      user.is_student?.should == false
    end

    specify "#is_guardian? returns true" do
      user.is_guardian?.should == true
    end
  end
end