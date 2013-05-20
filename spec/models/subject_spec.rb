require 'spec_helper'

describe Subject, :focus do
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
end