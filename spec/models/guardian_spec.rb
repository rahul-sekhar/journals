require 'spec_helper'

describe Guardian do
  let(:profile){ build(:guardian) }
  let(:profile_type){ :guardian }
  let(:profile_class){ Guardian }

  it_behaves_like "a profile"

  describe "#name_with_type" do
    context "with one student" do
      it "returns the full name along with the profile type and the associated student" do
        profile.first_name = "Rahul"
        profile.last_name = "Sekhar"

        student = profile.students.first
        student.first_name = "Roly"
        student.last_name = "Dog"

        profile.name_with_type.should == "Rahul Sekhar (guardian of Roly Dog)"
      end  
    end

    context "with multiple students" do
      it "returns the full name along with the profile type and all the associated students names" do
        profile.first_name = "Rahul"
        profile.last_name = "Sekhar"

        profile.save

        student = profile.students.first
        student.first_name = "Roly"
        student.last_name = "Dog"
        student.save
        profile.students << create(:student, first_name: "John", last_name: "Doe")
        profile.students << create(:student, first_name: "Lucky", last_name: "Dog")

        profile.name_with_type.should == "Rahul Sekhar (guardian of John, Lucky, and Roly)"
      end  
    end
    
  end
end