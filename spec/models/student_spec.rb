require 'spec_helper'

describe Student do
  let(:profile){ build(:student) }
  let(:profile_type){ :student }
  let(:profile_class){ Student }

  it_behaves_like "a profile"

  describe "on destruction" do
    it "destroys a guardian without other students" do
      create(:guardian, students: [profile])
      expect { profile.destroy }.to change { Guardian.count }.by(-1)
    end

    it "removes iteslf from a guardian with other students" do
      guardian = create(:guardian)
      guardian.students << profile
      guardian.students.exists?(profile).should == true
      profile.destroy
      guardian.students.exists?(profile).should == false
    end

    it "does not destroy a guardian with other students" do
      guardian = create(:guardian)
      guardian.students << profile
      expect { profile.destroy }.to change { Guardian.count }.by(0)
    end

    it "destroys any student observations" do
      profile.save!
      create(:student_observation, student: profile)
      expect { profile.destroy }.to change { StudentObservation.count }.by(-1)
    end
  end

  describe "#name_with_type" do
    it "returns the full name along with the profile type" do
      profile.first_name = "Rahul"
      profile.last_name = "Sekhar"
      profile.name_with_type.should == "Rahul Sekhar (student)"
    end
  end
end