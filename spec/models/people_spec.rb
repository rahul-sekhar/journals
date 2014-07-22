require 'spec_helper'

describe People do
  before do
    @student = create(:student, first_name: "Some", last_name: "Student")
    @teacher = create(:teacher, name: "Teacher")
    @guardian = create(:guardian, first_name: "Mr", last_name: "Guardian", students: [@student])
    @archived_student = create(:student, first_name: "Archived", last_name: "Student", archived: true)
  end

  it "returns student and teacher profiles" do
    People.all.map{ |person| person.profile }.should match_array [@student, @teacher, @archived_student]
  end

  it "returns full names" do
    People.all.map{ |person| person.full_name }.should match_array ["Some Student", "Teacher", "Archived Student"]
  end

  it "returns the archived status" do
    People.all.map{ |person| person.archived }.should match_array [true, false, false]
  end

  describe "#current" do
    it "does not return archived students" do
      People.current.map{ |person| person.profile }.should match_array [@student, @teacher]
    end
  end

  describe "#archived" do
    it "returns only archived students" do
      People.archived.map{ |person| person.profile }.should match_array [@archived_student]
    end
  end

  describe "##search" do
    it "searches the full name case insensitively" do
      People.search("chived stud").map{ |person| person.profile }.should == [@archived_student]
      People.search("teach").map{ |person| person.profile }.should == [@teacher]
    end

    it "returns an empty array with no matches" do
      People.search("something").should be_empty
    end

    it "ignores wildcards" do
      People.search("stud%").should be_empty
    end

    it "returns everything when passed a blank string" do
      People.search("").map{ |person| person.profile }.should match_array [@student, @teacher, @archived_student]
    end
  end
end