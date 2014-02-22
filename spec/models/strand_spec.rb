require 'spec_helper'

describe Strand, :c do
  let(:strand){ build(:strand) }

  it "is valid with valid attributes" do
    strand.should be_valid
  end

  it "is invalid without a subject" do
    strand.subject = nil
    strand.should be_invalid
  end

  describe 'headings' do
    before { strand.name = 'Subject' }
    describe 'for a parent strand' do
      it 'contains the strand name' do
        strand.headings.should eq ['Subject']
      end
    end

    describe 'for a child strand' do
      before do
        @subject = create(:subject)
        @source = create(:strand, subject: @subject, name: 'Source')
        @child1 = create(:strand, subject: @subject, parent_strand: @source, name: 'Child 1')
        @child2 = create(:strand, subject: @subject, parent_strand: @child1, name: 'Child 2')
      end

      it 'returns an array of strand headings' do
        @child2.headings.should eq ['Source', 'Child 1', 'Child 2']
      end
    end
  end

  describe "position" do
    it "is set to 1 when no other strands exist" do
      create(:strand).position.should eq(1)
    end

    describe 'when other strands exist' do
      before do
        @subject = create(:subject)
        @parent_strand = create(:strand, subject: @subject)
        @strand = create(:strand, subject: @subject, parent_strand: @parent_strand)
      end

      it 'is set to 1 for a new strand with a different subject and parent' do
        strand = create(:strand)
        strand.position.should eq(1)
      end

      it 'is set to 1 for a new strand with the same subject and a different parent' do
        create(:strand, subject: @subject, parent_strand: create(:strand)).position.should eq(1)
      end

      describe 'with some sibling strands' do
        before do
          @strand1 = create(:strand, subject: @subject, parent_strand: @parent_strand)
          @strand2 = create(:strand, subject: @subject, parent_strand: @parent_strand)
          @strand3 = create(:strand, subject: @subject, parent_strand: @parent_strand)
        end

        it 'is set successively' do
          @strand1.position.should eq(2)
          @strand2.position.should eq(3)
          @strand3.position.should eq(4)
        end

        it 'is preserved when a middle strand is deleted' do
          @strand1.destroy
          @strand.reload.position.should eq(1)
          @strand2.reload.position.should eq(2)
          @strand3.reload.position.should eq(3)
        end

        it 'is preserved when an end strand is deleted' do
          @strand3.destroy
          @strand.reload.position.should eq(1)
          @strand1.reload.position.should eq(2)
          @strand2.reload.position.should eq(3)
        end
      end
    end
  end

  describe "name" do
    it "is required" do
      strand.name = nil
      strand.should be_invalid
    end

    it "has a maximum length of 80 characters" do
      strand.name = "a" * 80
      strand.should be_valid
      strand.name = "a" * 81
      strand.should be_invalid
    end

    it "is trimmed of extra whitespace" do
      strand.name = "Blah "
      strand.save
      strand.reload.name.should == "Blah"
    end
  end

  describe "#add_strand" do
    describe "with no milestones" do
      before do
        strand.save!
        @child_strand = strand.add_strand 'Child strand'
      end

      it "adds a child strand" do
        @child_strand.name.should eq('Child strand')
        @child_strand.subject.should eq(strand.subject)
        @child_strand.should_not be_new_record
        @child_strand.parent_strand_id.should eq(strand.id)
      end
    end

    describe "with a milestone" do
      before do
        strand.save!
        strand.add_milestone 1, 'asdf'
      end

      it "raises an error" do
        expect{ strand.add_strand 'Child strand' }.to raise_error('Strand cannot have both milestones and child strands')
      end
    end
  end

  describe "#add_milestone" do
    describe "with no child strands" do
      before do
        strand.save!
        @milestone = strand.add_milestone 3, 'Milestone content'
      end

      it "adds a milestone" do
        @milestone.content.should eq('Milestone content')
        @milestone.strand.should eq(strand)
        @milestone.should_not be_new_record
        @milestone.level.should eq(3)
      end
    end

    describe "with child strands" do
      before do
        strand.save!
        @milestone = strand.add_strand 'asdf'
      end

      it "raises an error" do
        expect{ strand.add_milestone 3, 'Milestone content' }.to raise_error('Strand cannot have both milestones and child strands')
      end
    end
  end

  describe "on destruction" do
    it "destroys any child strands" do
      strand.save!
      strand.add_strand('Child strand')
      expect { strand.destroy }.to change { Strand.count }.by(-2)
    end

    it "destroys any milestones" do
      strand.save!
      strand.add_milestone(1, 'Some milestone')
      expect { strand.destroy }.to change { Milestone.count }.by(-1)
    end
  end
end