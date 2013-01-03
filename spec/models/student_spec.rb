require 'spec_helper'

describe Student do
  let(:student){ build(:student) }

  it "is valid with valid attributes" do
    student.should be_valid
  end

  it "is invalid without a last name" do
    student.last_name = nil
    student.should be_invalid
  end

  describe "email" do
    it "is required for a new record" do
      student.email = nil
      student.should be_invalid
    end

    it "must have the correct format" do
      student.email = "blah@gah"
      student.should be_invalid
      student.email = "blah@gah.com"
      student.should be_valid
    end

    it "must be unique" do
      create(:student, email: "test@mail.com")
      student.email = "test@mail.com"
      student.should be_invalid
    end

    it "is not required for a saved record" do
      student.save!
      student.email = nil
      student.should be_valid
    end
  end

  describe "password" do
    it "is required for a new record" do
      student.password = nil
      student.should be_invalid
    end

    it "must have at least four characters" do
      student.password = "pas"
      student.should be_invalid
    end

    it "cannot have spaces" do
      student.password = "blah blah"
      student.should be_invalid
    end

    it "is not required for a saved record" do
      student.save!
      student.password = nil
      student.should be_valid
    end
  end

  it "trims the first name" do
    student.first_name = " Rahul  "
    student.save!
    student.reload.first_name.should == "Rahul"
  end

  it "trims the last name" do
    student.last_name = " Rahul  "
    student.save!
    student.reload.last_name.should == "Rahul"
  end

  describe "#full_name" do
    it "joins the first and last names" do
      student.first_name = "Rahul"
      student.last_name = "Sekhar"
      student.full_name.should == "Rahul Sekhar"
    end

    it "returns the last name if the first name doesn't exist" do
      student.first_name = nil
      student.last_name = "Sekhar"
      student.full_name.should == "Sekhar"
    end
  end

  describe "on creation" do
    it "creates a user" do
      expect{ student.save! }.to change{ User.count }.by(1)
    end

    it "has a user" do
      student.save!
      student.user.should be_present
    end

    describe "the created user" do
      let(:user){ student.user }

      it "has the password passed to the profile" do
        student.password = "pass"
        student.save!
        User.authenticate(user.email, "pass").should eq(user)
      end

      it "has the email passed to the profile" do
        student.email = "test@mail.com"
        student.save!
        user.email.should == "test@mail.com"
      end
    end
  end

  describe "on destruction" do
    it "destroys the associated user" do
      student.save!
      expect { student.destroy }.to change{ User.count }.by(-1)
    end
  end

  describe "##find_by_name" do
    it "returns nil when no such profile exists" do
      create(:student, first_name: "Some", last_name: "Chap")
      Student.find_by_name("Other", "Chap").should be_nil
    end

    it "returns the matched profile if it exists" do
      profile = create(:student, first_name: "Some", last_name: "Chap")
      Student.find_by_name("Some", "Chap").should eq(profile)
    end
  end

describe "#name" do
    it "returns the first name if no duplicates exist" do
      student.first_name = "Rahul"
      student.name.should == "Rahul"
    end

    it "returns the full name if another student profile with the same first name exists" do
      create(:student, first_name: "Rahul")
      student.first_name = "Rahul"
      student.name.should == student.full_name
    end

    it "returns the full name if another GENERAL profile with the same first name exists"
  end
end