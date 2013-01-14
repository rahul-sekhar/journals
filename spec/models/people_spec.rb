require 'spec_helper'

describe People do
  before do
    @student = create(:student, first_name: "Some", last_name: "Student")
    @teacher = create(:teacher, first_name: "A", last_name: "Teacher")
    @guardian = create(:guardian, first_name: "Mr", last_name: "Guardian", students: [@student])
    @archived_student = create(:student, first_name: "Archived", last_name: "Student", archived: true)
  end

  it "returns student and teacher profiles" do
    People.all.map{ |person| person.profile }.should =~ [@student, @teacher, @archived_student]
  end

  it "returns full names" do
    People.all.map{ |person| person.full_name }.should =~ ["Some Student", "A Teacher", "Archived Student"]
  end

  it "returns the archived status" do
    People.all.map{ |person| person.archived }.should =~ [true, false, false]
  end

  describe "#current" do
    it "does not return archived students" do
      People.current.map{ |person| person.profile }.should =~ [@student, @teacher]
    end
  end

  describe "#archived" do
    it "returns only archived students" do
      People.archived.map{ |person| person.profile }.should =~ [@archived_student]
    end
  end

  describe "##search" do
    it "searches the full name case insensitively" do
      People.search("stud").map{ |person| person.profile }.should =~ [@student, @archived_student]
      People.search("a teach").map{ |person| person.profile }.should == [@teacher]
    end

    it "returns an empty array with no matches" do
      People.search("something").should be_empty
    end

    it "ignores wildcards" do
      People.search("stud%").should be_empty
    end
  end
end