require 'spec_helper'

describe TeacherProfile do
  let(:teacher_profile){ build(:teacher_profile) }

  it "is valid with valid attributes" do
    teacher_profile.should be_valid
  end

  it "is invalid without a last name" do
    teacher_profile.last_name = nil
    teacher_profile.should be_invalid
  end

  it "is invalid without a password when it is a new record" do
    teacher_profile.password = nil
    teacher_profile.should be_invalid
  end

  it "is valid without a password when it is not a new record" do
    teacher_profile.save
    teacher_profile.password = nil
    teacher_profile.should be_valid
  end

  describe "#full_name" do
    it "joins the first and last names" do
      teacher_profile.first_name = "Rahul"
      teacher_profile.last_name = "Sekhar"
      teacher_profile.full_name.should == "Rahul Sekhar"
    end

    it "returns the last name if the first name doesn't exist" do
      teacher_profile.first_name = nil
      teacher_profile.last_name = "Sekhar"
      teacher_profile.full_name.should == "Sekhar"
    end
  end

  describe "on creation" do
    it "creates a user" do
      expect{ teacher_profile.save! }.to change{ User.count }.by(1)
    end

    it "has a user" do
      teacher_profile.save!
      teacher_profile.user.should be_present
    end

    describe "the created user" do
      let(:user){ teacher_profile.user }

      it "has the password passed to the profile" do
        teacher_profile.password = "pass"
        teacher_profile.save!
        User.authenticate(user.username, "pass").should eq(user)
      end

      describe "username creation" do
        it "converts the first name to small letters" do
          teacher_profile.first_name = "Rahul"
          teacher_profile.last_name = "Sekhar"
          teacher_profile.save!
          user.username.should == "rahul"
        end

        it "uses the last name if the first name is not present" do
          teacher_profile.first_name = nil
          teacher_profile.last_name = "Sekhar"
          teacher_profile.save!
          user.username.should == "sekhar"
        end

        it "converts spaces to underscores" do
          teacher_profile.first_name = "Blah 1 Gah"
          teacher_profile.save!
          user.username.should == "blah_1_gah"
        end

        it "removes symbols" do
          teacher_profile.first_name = nil
          teacher_profile.last_name = "Bl-2a h*ga# &h"
          teacher_profile.save!
          user.username.should == "bl2a_hga_h"
        end

        context "if a duplicate exists" do
          before do
            create(:teacher_profile, first_name: "Blah Gah", last_name: "Pah")
            teacher_profile.first_name = "Bl&ah* ga#&h"
            teacher_profile.last_name = "Tch&5 ah"
          end

          it "uses the full name" do
            teacher_profile.save!
            user.username.should == "blah_gah_tch5_ah"
          end

          context "if a duplicate the full name exists" do
            before{ create(:teacher_profile, first_name: "Blah Gah", last_name: "Tch5 ah") }

            it "appends a number to the end of the username" do
              teacher_profile.save!
              user.username.should == "blah_gah_tch5_ah_1"
            end

            it "increments the number if further duplicates are found" do
              create(:teacher_profile, first_name: "Blah Gah", last_name: "Tch5 ah")
              create(:teacher_profile, first_name: "Blah Gah", last_name: "Tch5 ah")

              teacher_profile.save!
              user.username.should == "blah_gah_tch5_ah_3"
            end
          end
        end
      end
    end
  end
end