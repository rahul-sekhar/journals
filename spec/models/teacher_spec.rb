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

  it "is invalid without a password when it is a new record" do
    teacher.password = nil
    teacher.should be_invalid
  end

  describe "password" do
    it "must have at least four characters" do
      teacher.password = "pas"
      teacher.should be_invalid
    end

    it "cannot have spaces" do
      teacher.password = "blah blah"
      teacher.should be_invalid
    end
  end

  it "is valid without a password when it is not a new record" do
    teacher.save!
    teacher.password = nil
    teacher.should be_valid
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
        User.authenticate(user.username, "pass").should eq(user)
      end

      describe "username creation" do
        it "converts the first name to small letters" do
          teacher.first_name = "Rahul"
          teacher.last_name = "Sekhar"
          teacher.save!
          user.username.should == "rahul"
        end

        it "uses the last name if the first name is not present" do
          teacher.first_name = nil
          teacher.last_name = "Sekhar"
          teacher.save!
          user.username.should == "sekhar"
        end

        it "converts spaces to underscores" do
          teacher.first_name = "Blah 1 Gah"
          teacher.save!
          user.username.should == "blah_1_gah"
        end

        it "removes symbols" do
          teacher.first_name = nil
          teacher.last_name = "Bl-2a h*ga# &h"
          teacher.save!
          user.username.should == "bl2a_hga_h"
        end

        context "if a duplicate exists" do
          before do
            create(:teacher, first_name: "Blah Gah", last_name: "Pah")
            teacher.first_name = "Bl&ah* ga#&h"
            teacher.last_name = "Tch&5 ah"
          end

          it "uses the full name" do
            teacher.save!
            user.username.should == "blah_gah_tch5_ah"
          end

          context "with a duplicate full name" do
            before{ create(:teacher, first_name: "Blah Gah", last_name: "Tch5 ah") }

            it "appends a number to the end of the username" do
              teacher.save!
              user.username.should == "blah_gah_tch5_ah_1"
            end

            it "increments the number if further duplicates are found" do
              create(:teacher, first_name: "Blah Gah", last_name: "Tch5 ah")
              create(:teacher, first_name: "Blah Gah", last_name: "Tch5 ah")

              teacher.save!
              user.username.should == "blah_gah_tch5_ah_3"
            end
          end
        end
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