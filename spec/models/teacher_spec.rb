require 'spec_helper'

describe Teacher do
  let(:profile){ build(:teacher) }
  let(:profile_type){ :teacher }
  let(:profile_class){ Teacher }

  it_behaves_like "a profile"

  describe "#name_with_type" do
    it "returns the full name along with the profile type" do
      profile.first_name = "Rahul"
      profile.last_name = "Sekhar"
      profile.name_with_type.should == "Rahul Sekhar (teacher)"
    end
  end
end