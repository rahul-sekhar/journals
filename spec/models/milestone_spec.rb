require 'spec_helper'

describe Milestone, :focus do
  let(:milestone){ build(:milestone) }

  it "is valid with valid attributes" do
    milestone.should be_valid
  end

  it "is invalid without a strand" do
    milestone.strand = nil
    milestone.should be_invalid
  end

  describe "position" do
    it "is set to 1 when no other milestones exist" do
      create(:milestone).position.should eq(1)
    end

    describe 'when other milestones exist' do
      before do
        @strand = create(:strand)
        @milestone = create(:milestone, strand: @strand)
      end

      it 'is set to 1 for a new milestone with a different strand' do
        milestone = create(:milestone)
        milestone.position.should eq(1)
      end

      it 'is set to 1 for a new milestone with the same strand and a different level' do
        create(:milestone, strand: @strand, level: 2).position.should eq(1)
      end

      describe 'with some sibling milestones' do
        before do
          @milestone1 = create(:milestone, strand: @strand)
          @milestone2 = create(:milestone, strand: @strand)
          @milestone3 = create(:milestone, strand: @strand)
        end

        it 'is set successively' do
          @milestone1.position.should eq(2)
          @milestone2.position.should eq(3)
          @milestone3.position.should eq(4)
        end

        it 'is preserved when a middle milestone is deleted' do
          @milestone1.destroy
          @milestone.reload.position.should eq(1)
          @milestone2.reload.position.should eq(2)
          @milestone3.reload.position.should eq(3)
        end

        it 'is preserved when an end milestone is deleted' do
          @milestone3.destroy
          @milestone.reload.position.should eq(1)
          @milestone1.reload.position.should eq(2)
          @milestone2.reload.position.should eq(3)
        end
      end
    end
  end
end