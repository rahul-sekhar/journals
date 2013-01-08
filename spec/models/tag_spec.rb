require 'spec_helper'

describe Tag do
  let(:tag){ build(:tag) }

  it "is valid with valid attributes" do
    tag.should be_valid
  end

  describe "name" do
    it "is required" do
      tag.name = nil
      tag.should be_invalid
    end
    
    it "must be unique" do
      create(:tag, name: "some-tag")
      tag.name = "Some-Tag"
      tag.should be_invalid
    end

    it "must be unique with whitespace" do
      create(:tag, name: "some-tag")
      tag.name = "Some-Tag "
      tag.should be_invalid
    end

    it "has a maximum length of 50 characters" do
      tag.name = "a" * 50
      tag.should be_valid
      tag.name = "a" * 51
      tag.should be_invalid
    end

    it "is trimmed of extra whitespace" do
      tag.name = "Blah "
      tag.save
      tag.reload.name.should == "Blah"
    end
  end

  describe "##name_is" do
    before { @existing_tag = create(:tag, name: "Some Tag") }
    
    it "returns nil no matching tags exist" do
      returned_tag = Tag.name_is("Other Tag")
      returned_tag.should be_nil
    end

    it "returns a matching tag case insensitively" do
      returned_tag = Tag.name_is("some TAG")
      returned_tag.should eq(@existing_tag)
    end
  end
  
  describe "##find_or_build_list" do
    subject(:result) { Tag.find_or_build_list( tag_list ) }

    context "for a blank string" do
      let(:tag_list){ " " }
      it { should be_empty }
    end

    context "for a single new name" do
      let(:tag_list){ "New Tag" }
      
      it "returns a single tag" do
        result.length.should == 1
        result.first.should be_a Tag
      end

      describe "the returned tag" do
        it "has the passed name" do
          result.first.name.should == "New Tag"
        end

        it "is a new record" do
          result.first.should be_new_record
        end
      end

      context "when untrimmed" do
        let(:tag_list){ "  New Tag " }

        specify "the returned tag is trimmed" do
          result.first.name.should == "New Tag"
        end
      end
    end

    context "for a single existing name" do
      let(:tag_list){ "Existing Tag" }
      before{ @existing_tag = Tag.create!(name: "Existing Tag") }

      it "returns a single tag" do
        result.length.should == 1
      end

      it "returns the existing tag" do
        result.first.should == @existing_tag
      end

      context "when passed a different case and untrimmed" do
        let(:tag_list){ " existing tag "}

        it "returns the existing tag" do
          result.first.should == @existing_tag
        end
      end
    end

    context "for multiple names, some of which exist" do
      let(:tag_list){ "  Tag1,  another tag, a new tag, tag4" }
      before do 
        @tag4 = Tag.create!(name: "Tag4")
        @another_tag = Tag.create!(name: "Another Tag")
      end

      it "returns as many tags as names exist" do
        result.length.should == 4
      end

      it "returns the two existing records" do
        result.should include(@tag4)
        result.should include(@another_tag)
      end

      it "returns tags with have the correct names" do
        result.map{ |tag| tag.name }.should =~ ["Tag1", "Another Tag", "a new tag", "Tag4"]
      end
    end

    context "when passed blank values" do
      let(:tag_list){ "Tag1, ,tag2" }
      before{ @tag1 = Tag.create!(name: "Tag1") }

      it "ignores the blank values" do
        result.length.should == 2
      end

      it "returns existing tags" do
        result.should include @tag1
      end

      it "returns tags with the correct names" do
        result.map{ |tag| tag.name }.should =~ ["Tag1", "tag2"]
      end
    end

    context "when passed duplicate tags" do
      let(:tag_list){ "tag1, Tag2, TAG1, tag3, tag3" }
      before{ @tag1 = Tag.create!(name: "TAG1") }

      it "ignores duplicates" do
        result.length.should == 3
      end

      it "returns existing tags" do
        result.should include @tag1
      end

      it "returns tags with the correct names" do
        result.map{ |tag| tag.name }.should =~ ["TAG1", "Tag2", "tag3"]
      end
    end
  end
end