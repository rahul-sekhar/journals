shared_examples_for "a profile" do
  it "is valid with valid attributes" do
    profile.should be_valid
  end

  it "is invalid without a last name" do
    profile.last_name = nil
    profile.should be_invalid
  end

  describe "#email=" do
    it "sets the users email" do
      profile.email = "some@mail.com"
      profile.user.email.should == "some@mail.com"
    end

    it "can be set on creation of the profile" do
      prof = profile_class.create!(last_name: "Name", email: "blah@blah.com")
      prof.user.email.should == "blah@blah.com"
    end

    it "is invalid with an invalid email" do
      profile.email = "blah@gah"
      profile.should be_invalid
    end

    it "is valid with a valid email" do
      profile.email = "blah@gah.com"
      profile.should be_valid
    end

    it "is invalid with a duplicate email" do
      create(:student, email: "test@mail.com")
      profile.email = "test@mail.com"
      profile.should be_invalid
    end
  end

  describe "#email" do
    it "returns the users email" do
      profile.user.stub(:email).and_return("some-email")
      profile.email.should == "some-email"
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

  describe "#name" do
    it "returns the first_name" do
      profile.first_name = "Rahul"
      profile.name.should == "Rahul"
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

      it "is inactive" do
        profile.save!
        user.should_not be_active
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

  describe "##alphabetical" do
    it "orders alphabetically by the first name followed by the last name" do
      profile1 = create(profile_type, first_name: "Some", last_name: "Fellow")
      profile2 = create(profile_type, first_name: "Another", last_name: "Fellow")
      profile3 = create(profile_type, first_name: "Some", last_name: "Chap")
      profile_class.alphabetical.should == [profile2, profile3, profile1]
    end    
  end

  describe "##fields" do
    it "returns an array of hashes of fields" do
      profile_class.fields.should be_a Array
      profile_class.fields.first.should be_a Hash
    end

    it "must include email" do
      profile_class.fields.find{ |field| field[:name] == "Email" }.should be_present
    end
  end
end