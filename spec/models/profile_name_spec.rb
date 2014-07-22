require 'spec_helper'

describe ProfileName do
  context "with a student" do
    let(:student) { create(:student, first_name: "Some", last_name: "Name") }
    before{ student }

    it "returns the first name" do
      ProfileName.first.first_name.should == "Some"
    end

    it "returns the initial" do
      ProfileName.first.initial.should == "N"
    end

    it "has the student as a profile" do
      ProfileName.first.profile.should == student
    end
  end

  context "with a teacher" do
    let(:guardian) { create(:teacher, first_name: "Other", last_name: "Name") }
    before{ guardian }

    it "returns the first name" do
      ProfileName.first.first_name.should == "Other"
    end

    it "returns the initial" do
      ProfileName.first.initial.should == "N"
    end

    it "has the guardian as a profile" do
      ProfileName.first.profile.should == guardian
    end
  end

  context "with a guardian" do
    let(:guardian) { create(:guardian, first_name: "Some", last_name: "Guardian") }
    before{ guardian }

    it "returns the first name" do
      ProfileName.where(profile_type: "Guardian").first.first_name.should == "Some"
    end

    it "returns the initial" do
      ProfileName.where(profile_type: "Guardian").first.initial.should == "G"
    end

    it "has the guardian as a profile" do
      ProfileName.where(profile_type: "Guardian").first.profile.should == guardian
    end
  end

  context "with a guardian, student and teacher, all with the same name" do
    let(:student) { create(:student, first_name: "Some", last_name: "Name") }
    let(:guardian) { create(:guardian, first_name: "Some", last_name: "Name", students: [student]) }
    let(:teacher) { create(:teacher, first_name: "Some", last_name: "Name") }

    before do
      student
      guardian
      teacher
    end

    it "returns three entries" do
      ProfileName.count.should == 3
    end

    it "returns all three first names" do
      ProfileName.all.map{ |profile| profile.first_name }.should == ["Some", "Some", "Some"]
    end

    it "returns all three initials" do
      ProfileName.all.map{ |profile| profile.initial }.should == ["N", "N", "N"]
    end

    it "returns all three profiles" do
      ProfileName.all.map{ |profile| profile.profile }.should match_array [student, guardian, teacher]
    end
  end

  context "with single named profiles" do
    before do
      @student = create(:student, name: 'Single')
      @teacher = create(:teacher, name: 'One')
      @guardian = create(:guardian, name: 'Un', students: [@student])
    end

    it "returns all the profiles" do
      ProfileName.all.map{ |profile| profile.profile }.should match_array [@student, @teacher, @guardian]
    end
  end

  describe "##excluding_profile" do
    let(:student) { create(:student, first_name: "Some", last_name: "Name") }
    let(:student2) { create(:student, first_name: "Some", last_name: "Name") }
    let(:guardian) { create(:guardian, first_name: "Some", last_name: "Name", students: [student]) }
    let(:teacher) { create(:teacher, first_name: "Some", last_name: "Name") }

    before do
      student
      student2
      guardian
      teacher
    end
    it "exludes the passed profile" do
      return_val = ProfileName.excluding_profile(student).all
      return_val.map{ |profile| profile.profile }.should match_array [student2, guardian, teacher]
    end
  end
end