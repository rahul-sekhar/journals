require 'spec_helper'

describe Student do
  let(:profile){ build(:student) }
  let(:profile_type){ :student }
  let(:profile_class){ Student }

  it_behaves_like "a profile"

  describe "on destruction" do
    it "destroys any guardians" do
      profile.save!
      create(:guardian, student: profile)
      expect { profile.destroy }.to change{ Guardian.count }.by(-1)
    end
  end
end