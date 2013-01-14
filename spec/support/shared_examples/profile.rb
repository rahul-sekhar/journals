shared_examples_for "a profile" do
  it "is valid with valid attributes" do
    profile.should be_valid
  end

  it "is invalid without a first_name or last name" do
    profile.first_name = nil
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

    it "is set to the first name if not present" do
      profile.first_name = "Something"
      profile.last_name = nil
      profile.save!
      profile.reload.first_name.should be_nil
      profile.reload.last_name.should == "Something"
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
    subject{ profile.name }
    before do
      profile.first_name = "Rahul"
      profile.last_name = "Sekhar"
      profile.save!
    end

    context "with no duplicates" do
      context "if there is no first_name" do
        before do
          profile.first_name = " "
          profile.save!
        end

        it { should == "Sekhar" }
      end

      it { should == "Rahul" }
    end

    context "with a duplicate first name" do
      before{ create(:student, first_name: "Rahul", last_name: "Raj") }

      it { should == "Rahul S." }

      context "with a duplicate first name and initial" do
        before{ create(:student, first_name: "Rahul", last_name: "Sharma") }

        it { should == "Rahul Sekhar" }
      end

      context "with a duplicate full name" do
        before{ create(:student, first_name: "Rahul", last_name: "Sekhar") }

        it { should == "Rahul Sekhar" }
      end
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

  describe "##name_is" do
    before do
      @profile1 = profile_class.create(first_name: "First", last_name: "Last")
      @profile2 = profile_class.create(first_name: "First")
    end

    it "returns a profile with passed names" do
      profile_class.name_is("First", "Last").should == @profile1
    end

    it "returns nil if no match was found" do
      profile_class.name_is("Some", "Last").should be_nil
    end

    it "matches names case insensitively" do
      profile_class.name_is("first", "last").should == @profile1
    end

    it "matches profiles with only single names" do
      profile_class.name_is("first", nil).should == @profile2
      profile_class.name_is("first", " ").should == @profile2
    end

    it "ignores wildcards" do
      profile.class.name_is("fir%", "last").should be_nil
    end
  end

  describe "##names_are" do
    before do
      @profile1 = profile_class.create(first_name: "First", last_name: "Last")
      @profile2 = profile_class.create(first_name: "First", last_name: "last")
      @profile3 = profile_class.create(first_name: "First")
    end

    it "returns profiles with passed names" do
      profile_class.names_are("first", "last").should == [@profile1, @profile2]
    end

    it "returns an empty array if no match was found" do
      profile_class.names_are("Some", "Last").should be_empty
    end

    it "matches profiles with only single names" do
      profile_class.names_are("first", nil).should == [@profile3]
      profile_class.names_are("first", " ").should == [@profile3]
    end

    it "ignores wildcards" do
      profile.class.names_are("fir%", "last").should be_empty
    end
  end

  describe "##search" do
    before do
      @profile1 = create(profile_type, first_name: "Some", last_name: "Profile")
      @profile2 = create(profile_type, first_name: "Other", last_name: "Profile")
      @profile3 = create(profile_type, first_name: nil, last_name: "Person")
    end

    it "searches the first name" do
      profile_class.search("Some").should == [@profile1]
    end

    it "searches the last name" do
      profile_class.search("Person").should =~ [@profile3]
    end

    it "searches case insensitively" do
      profile_class.search("person").should == [@profile3]
    end

    it "matches partial results" do
      profile_class.search("so").should =~ [@profile1, @profile3]
    end

    it "returns all results when the query is empty" do
      profile_class.search("").should =~ [@profile1, @profile2, @profile3]
    end

    it "matches the full name" do
      profile_class.search("r prof").should == [@profile2]
    end

    it "returns an empty array when there are no matches" do
      profile_class.search("asdf").should be_empty
    end

    it "ignores wildcards" do
      profile_class.search("So%").should be_empty
    end
  end
end