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

    it "is invalid when more than 60 characters" do
      profile.email = "a" * 51 + "@email.com"
      profile.should be_invalid
    end

    it "can be set to nil and set again before being saved" do
      profile.email = "some@mail.com"
      profile.email = nil
      profile.email = "some_other@mail.com"
      profile.save!
      profile.reload.email.should == "some_other@mail.com"
    end

    it "can be set to nil after being set to a value" do
      profile.email = "some@mail.com"
      profile.email = nil
      profile.save!
      profile.reload.email.should be_nil
    end

    context "after email is set and saved" do
      before do
        profile.email = "some@mail.com"
        profile.save!
      end

      it "can be edited for an already saved profile" do
        profile.email = "another@mail.com"
        profile.save!
        profile.reload.email.should == "another@mail.com"
      end

      it "can be edited after being set to nil" do
        profile.email = nil
        profile.email = "another@mail.com"
        profile.save!
        profile.reload.email.should == "another@mail.com"
      end

      it "destroys the user when set with a nil email" do
        profile.email = nil
        expect{ profile.save! }.to change{ User.count }.by(-1)
      end
    end

    it "is valid with a blank email" do
      profile.email = " "
      profile.should be_valid
    end
  end

  describe "#email" do
    it "returns the users email" do
      user = double('user')
      profile.stub(:user).and_return(user)
      user.stub(:email).and_return("some-email")
      profile.email.should == "some-email"
    end

    it "returns nil if there is no user" do
      profile.email.should be_nil
    end

    it "returns nil if set to nil" do
      profile.email = "some@mail.com"
      profile.save!
      profile.email = nil
      profile.save!
      profile.reload.email.should be_nil
    end
  end

  describe "#first_name" do
    it "is trimmed" do
      profile.first_name = " Rahul  "
      profile.save!
      profile.reload.first_name.should == "Rahul"
    end

    it "cannot be more than 80 characters" do
      profile.first_name = "a" * 80
      profile.should be_valid
      profile.first_name = "a" * 81
      profile.should be_invalid
    end
  end

  describe "#last_name" do
    it "is trimmed" do
      profile.last_name = " Rahul  "
      profile.save!
      profile.reload.last_name.should == "Rahul"
    end

    it "cannot be more than 80 characters" do
      profile.last_name = "a" * 80
      profile.should be_valid
      profile.last_name = "a" * 81
      profile.should be_invalid
    end
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
    it "returns the first_name if present" do
      profile.first_name = "Rahul"
      profile.name.should == "Rahul"
    end

    it "returns the last name if the first name is not present" do
      profile.first_name = nil
      profile.last_name = "Sekhar"
      profile.name.should == "Sekhar"
    end
  end

  it "cannot have a mobile longer than 40 characters" do
    profile.mobile = "a" * 40
    profile.should be_valid
    profile.mobile = "a" * 41
    profile.should be_invalid
  end

  it "cannot have a home_phone longer than 40 characters" do
    profile.home_phone = "a" * 40
    profile.should be_valid
    profile.home_phone = "a" * 41
    profile.should be_invalid
  end

  it "cannot have a office_phone longer than 40 characters" do
    profile.office_phone = "a" * 40
    profile.should be_valid
    profile.office_phone = "a" * 41
    profile.should be_invalid
  end

  describe "#active?" do
    it "is inactive if the user is not present" do
      profile.should_not be_active
    end

    it "returns the users active status if the user is present" do
      user = double('user')
      profile.stub(:user).and_return(user)
      user.stub(:active?).and_return("status")
      profile.active?.should == "status"
    end
  end

  describe "#reset_password" do
    it "returns false if the user does not exist" do
      profile.reset_password.should == false
    end

    context "if the user exists" do
      before{ profile.email = "test@mail.com" }

      it "generates a password for the user" do
        profile.user.should_receive(:generate_password)
        profile.reset_password
      end

      it "returns the generated password" do
        profile.user.stub(:generate_password).and_return("generated-pass")
        profile.reset_password.should == "generated-pass"
      end

      it "saves the profile" do
        profile.should_receive(:save)
        profile.reset_password
      end

      it "activates an inactive profile" do
        profile.should_not be_active
        profile.reset_password
        profile.should be_active
      end
    end
  end

  describe "on creation" do
    it "creates a user if created with an email address" do
      profile.email = "test@mail.com"
      expect{ profile.save! }.to change{ User.count }.by(1)
    end

    it "does not create a user if created without an email address" do
      expect{ profile.save! }.to change{ User.count }.by(0)
    end

    it "the created user is inactive" do
      profile.email = "test@mail.com"
      profile.save!
      profile.user.should_not be_active
    end
  end

  describe "on destruction" do
    it "destroys the associated user" do
      profile.email = "test@mail.com"
      profile.save!
      expect { profile.destroy }.to change{ User.count }.by(-1)
    end

    it "destroys any posts" do
      profile.save!
      post = create(:post, author: profile)
      expect { profile.destroy }.to change { Post.count }.by(-1)
    end

    it "destroys any comments" do
      profile.save!
      create(:comment, author: profile)
      expect { profile.destroy }.to change { Comment.count }.by(-1)
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

  describe "##inputs" do
    before do
      profile_class.stub(:fields).and_return([
        { name: "Something", function: :something },
        { name: "Something Else", function: :something_else, input: :some_input }
      ])
    end

    it "returns either the function or the input of the field, giving preference to the input" do
      profile_class.inputs.should == [:something, :some_input]
    end
  end
end