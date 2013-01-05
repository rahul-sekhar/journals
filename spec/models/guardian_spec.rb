require 'spec_helper'

describe Guardian do
  let(:profile){ build(:guardian) }
  let(:profile_type){ :guardian }
  let(:profile_class){ Guardian }

  it_behaves_like "a profile"

  it "requires a student" do
    profile.student = nil
    profile.should be_invalid
  end

  describe "#name_with_type" do
    it "returns the full name along with the profile type and the associateed student" do
      profile.first_name = "Rahul"
      profile.last_name = "Sekhar"

      student = profile.student
      student.first_name = "Roly"
      student.last_name = "Dog"
      student.save
      profile.student.reload

      profile.name_with_type.should == "Rahul Sekhar (guardian of Roly Dog)"
    end
  end
end