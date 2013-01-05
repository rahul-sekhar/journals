shared_examples_for "a profile" do
  it "is valid with valid attributes" do
    profile.should be_valid
  end

  it "is invalid without a last name" do
    profile.last_name = nil
    profile.should be_invalid
  end

  describe "email" do
    it "is required for a new record" do
      profile.email = nil
      profile.should be_invalid
    end

    it "must have the correct format" do
      profile.email = "blah@gah"
      profile.should be_invalid
      profile.email = "blah@gah.com"
      profile.should be_valid
    end

    it "must be unique" do
      create(profile_type, email: "test@mail.com")
      profile.email = "test@mail.com"
      profile.should be_invalid
    end

    it "is not required for a saved record" do
      profile.save!
      profile.email = nil
      profile.should be_valid
    end
  end

  describe "password" do
    it "is required for a new record" do
      profile.password = nil
      profile.should be_invalid
    end

    it "must have at least four characters" do
      profile.password = "pas"
      profile.should be_invalid
    end

    it "cannot have spaces" do
      profile.password = "blah blah"
      profile.should be_invalid
    end

    it "is not required for a saved record" do
      profile.save!
      profile.password = nil
      profile.should be_valid
    end
  end

  it "trims the first name" do
    profile.first_name = " Rahul  "
    profile.save!
    profile.reload.first_name.should == "Rahul"
  end

  it "trims the last name" do
    profile.last_name = " Rahul  "
    profile.save!
    profile.reload.last_name.should == "Rahul"
  end

  describe "#full_name" do
    it "joins the first and last names" do
      profile.first_name = "Rahul"
      profile.last_name = "Sekhar"
      profile.full_name.should == "Rahul Sekhar"
    end

    it "returns the last name if the first name doesn't exist" do
      profile.first_name = nil
      profile.last_name = "Sekhar"
      profile.full_name.should == "Sekhar"
    end
  end

  describe "on creation" do
    it "creates a user" do
      profile
      expect{ profile.save! }.to change{ User.count }.by(1)
    end

    it "has a user" do
      profile.save!
      profile.user.should be_present
    end

    describe "the created user" do
      let(:user){ profile.user }

      it "has the password passed to the profile" do
        profile.password = "pass"
        profile.save!
        User.authenticate(user.email, "pass").should eq(user)
      end

      it "has the email passed to the profile" do
        profile.email = "test@mail.com"
        profile.save!
        user.email.should == "test@mail.com"
      end
    end
  end

  describe "on destruction" do
    it "destroys the associated user" do
      profile.save!
      expect { profile.destroy }.to change{ User.count }.by(-1)
    end
  end

  describe "##find_by_name" do
    it "returns nil when no such profile exists" do
      create(profile_type, first_name: "Some", last_name: "Chap")
      profile_class.find_by_name("Other", "Chap").should be_nil
    end

    it "returns the matched profile if it exists" do
      profile = create(profile_type, first_name: "Some", last_name: "Chap")
      profile_class.find_by_name("Some", "Chap").should eq(profile)
    end
  end

describe "#name" do
    it "returns the first name if no duplicates exist" do
      profile.first_name = "Rahul"
      profile.save
      profile.name.should == "Rahul"
    end

    it "returns the full name if another student with the same first name exists" do
      create(:student, first_name: "Rahul")
      profile.first_name = "Rahul"
      profile.name.should == profile.full_name
    end

    it "returns the full name if another teacher with the same first name exists" do
      create(:teacher, first_name: "Rahul")
      profile.first_name = "Rahul"
      profile.name.should == profile.full_name
    end

    it "returns the full name if another guardian with the same first name exists" do
      create(:guardian, first_name: "Rahul")
      profile.first_name = "Rahul"
      profile.name.should == profile.full_name
    end
  end

  describe "##alphabetical" do
    it "orders alphabetically by the first name followed by the last name" do
      profile1 = create(profile_type, first_name: "Some", last_name: "Fellow")
      profile2 = create(profile_type, first_name: "Another", last_name: "Fellow")
      profile3 = create(profile_type, first_name: "Some", last_name: "Chap")
      profile_class.alphabetical.should == [profile2, profile3, profile1]
    end    
  end
  
end