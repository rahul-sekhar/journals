require 'spec_helper'

describe Teacher do
  let(:teacher){ build(:teacher) }

  it "is valid with valid attributes" do
    teacher.should be_valid
  end

  it "is invalid without a last name" do
    teacher.last_name = nil
    teacher.should be_invalid
  end

  describe "email" do
    it "is required for a new record" do
      teacher.email = nil
      teacher.should be_invalid
    end

    it "must have the correct format" do
      teacher.email = "blah@gah"
      teacher.should be_invalid
      teacher.email = "blah@gah.com"
      teacher.should be_valid
    end

    it "must be unique" do
      create(:teacher, email: "test@mail.com")
      teacher.email = "test@mail.com"
      teacher.should be_invalid
    end

    it "is not required for a saved record" do
      teacher.save!
      teacher.email = nil
      teacher.should be_valid
    end
  end

  describe "password" do
    it "is required for a new record" do
      teacher.password = nil
      teacher.should be_invalid
    end

    it "must have at least four characters" do
      teacher.password = "pas"
      teacher.should be_invalid
    end

    it "cannot have spaces" do
      teacher.password = "blah blah"
      teacher.should be_invalid
    end

    it "is not required for a saved record" do
      teacher.save!
      teacher.password = nil
      teacher.should be_valid
    end
  end

  it "trims the first name" do
    teacher.first_name = " Rahul  "
    teacher.save!
    teacher.reload.first_name.should == "Rahul"
  end

  it "trims the last name" do
    teacher.last_name = " Rahul  "
    teacher.save!
    teacher.reload.last_name.should == "Rahul"
  end

  describe "#full_name" do
    it "joins the first and last names" do
      teacher.first_name = "Rahul"
      teacher.last_name = "Sekhar"
      teacher.full_name.should == "Rahul Sekhar"
    end

    it "returns the last name if the first name doesn't exist" do
      teacher.first_name = nil
      teacher.last_name = "Sekhar"
      teacher.full_name.should == "Sekhar"
    end
  end

  describe "on creation" do
    it "creates a user" do
      expect{ teacher.save! }.to change{ User.count }.by(1)
    end

    it "has a user" do
      teacher.save!
      teacher.user.should be_present
    end

    describe "the created user" do
      let(:user){ teacher.user }

      it "has the password passed to the profile" do
        teacher.password = "pass"
        teacher.save!
        User.authenticate(user.email, "pass").should eq(user)
      end

      it "has the email passed to the profile" do
        teacher.email = "test@mail.com"
        teacher.save!
        user.email.should == "test@mail.com"
      end
    end
  end

  describe "on destruction" do
    it "destroys the associated user" do
      teacher.save!
      expect { teacher.destroy }.to change{ User.count }.by(-1)
    end
  end

  describe "##find_by_name" do
    it "returns nil when no such profile exists" do
      create(:teacher, first_name: "Some", last_name: "Chap")
      Teacher.find_by_name("Other", "Chap").should be_nil
    end

    it "returns the matched profile if it exists" do
      profile = create(:teacher, first_name: "Some", last_name: "Chap")
      Teacher.find_by_name("Some", "Chap").should eq(profile)
    end
  end

describe "#name" do
    it "returns the first name if no duplicates exist" do
      teacher.first_name = "Rahul"
      teacher.name.should == "Rahul"
    end

    it "returns the full name if another teacher profile with the same first name exists" do
      create(:teacher, first_name: "Rahul")
      teacher.first_name = "Rahul"
      teacher.name.should == teacher.full_name
    end

    it "returns the full name if another GENERAL profile with the same first name exists"
  end
end