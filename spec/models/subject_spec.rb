require 'spec_helper'

describe Subject do
  let(:subject){ build(:subject) }

  it "is valid with valid attributes" do
    subject.should be_valid
  end

  describe "name" do
    it "is required" do
      subject.name = nil
      subject.should be_invalid
    end

    it "must be unique" do
      create(:subject, name: "some-subject")
      subject.name = "Some-Subject"
      subject.should be_invalid
    end

    it "must be unique with whitespace" do
      create(:subject, name: "some-subject")
      subject.name = "Some-Subject "
      subject.should be_invalid
    end

    it "has a maximum length of 50 characters" do
      subject.name = "a" * 50
      subject.should be_valid
      subject.name = "a" * 51
      subject.should be_invalid
    end

    it "is trimmed of extra whitespace" do
      subject.name = "Blah "
      subject.save
      subject.reload.name.should == "Blah"
    end
  end

  describe "#add_strand" do
    before do
      subject.save!
      @strand = subject.add_strand 'Strand Name'
    end

    it "adds a strand to the subject" do
      @strand.name.should eq('Strand Name')
      @strand.subject.should eq(subject)
      @strand.should_not be_new_record
      @strand.parent_strand_id.should be_nil
    end
  end

  describe "#root_strands" do
    before do
      @strand1 = create(:strand, subject: subject)
      @strand2 = create(:strand, subject: subject, parent_strand: @strand1)
      @strand3 = create(:strand, subject: subject)
    end

    it "returns only root strands" do
      subject.root_strands.should =~ [@strand1, @strand3]
    end
  end

  describe "#add_teacher" do
    let(:teacher) { create(:teacher) }
    before do
      subject.save!
      subject.add_teacher(teacher)
    end

    it "adds a teacher" do
      subject.teachers.should == [teacher]
      subject.subject_teachers.count.should == 1
      subject.subject_teachers.first.teacher.should == teacher
    end

    it "does not add the same teacher twice" do
      subject.add_teacher(teacher)
      subject.teachers.should == [teacher]
      subject.subject_teachers.count.should == 1
    end
  end

  describe "on destruction" do
    it "destroys any strands" do
      subject.save!
      subject.add_strand('Some strand')
      expect{ subject.destroy }.to change{ Strand.count }.by(-1)
    end

    it "destroys any units" do
      subject.save!
      create(:unit, subject: subject)
      expect{ subject.destroy }.to change{ Unit.count }.by(-1)
    end

    it "destroys any subject teachers" do
      subject.save!
      subject.add_teacher(create(:teacher))
      expect{ subject.destroy }.to change{ SubjectTeacher.count }.by(-1)
    end
  end
end