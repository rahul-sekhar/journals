shared_examples_for "a taggable object" do

  describe "##alphabetical" do
    it "returns the tags in alphabetical order" do
      @tag1 = object_class.create!(name: "Some tag")
      @tag2 = object_class.create!(name: "Some other tag")
      @tag3 = object_class.create!(name: "Ze tag")
      @tag4 = object_class.create!(name: "A tag")

      object_class.alphabetical.all.should == [@tag4, @tag2, @tag1, @tag3]
    end
  end

  describe "##name_is" do
    before { @existing_tag = object_class.create!(name: "Some Tag") }

    it "returns nil no matching tags exist" do
      returned_tag = object_class.name_is("Other Tag")
      returned_tag.should be_nil
    end

    it "returns a matching tag case insensitively" do
      returned_tag = object_class.name_is("some TAG")
      returned_tag.should eq(@existing_tag)
    end
  end

  describe "##find_or_build_list" do
    subject(:result) { object_class.find_or_build_list( tag_list ) }

    context "for a blank string" do
      let(:tag_list){ " " }
      it { should be_empty }
    end

    context "for a single new name" do
      let(:tag_list){ "New Tag" }

      it "returns a single tag" do
        result.length.should == 1
        result.first.should be_a object_class
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
      before{ @existing_tag = object_class.create!(name: "Existing Tag") }

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
        @tag4 = object_class.create!(name: "Tag4")
        @another_tag = object_class.create!(name: "Another Tag")
      end

      it "returns as many tags as names exist" do
        result.length.should == 4
      end

      it "returns the two existing records" do
        result.should include(@tag4)
        result.should include(@another_tag)
      end

      it "returns tags with have the correct names" do
        result.map{ |tag| tag.name }.should match_array ["Tag1", "Another Tag", "a new tag", "Tag4"]
      end
    end

    context "when passed blank values" do
      let(:tag_list){ "Tag1, ,tag2" }
      before{ @tag1 = object_class.create!(name: "Tag1") }

      it "ignores the blank values" do
        result.length.should == 2
      end

      it "returns existing tags" do
        result.should include @tag1
      end

      it "returns tags with the correct names" do
        result.map{ |tag| tag.name }.should match_array ["Tag1", "tag2"]
      end
    end

    context "when passed duplicate tags" do
      let(:tag_list){ "tag1, Tag2, TAG1, tag3, tag3" }
      before{ @tag1 = object_class.create!(name: "TAG1") }

      it "ignores duplicates" do
        result.length.should == 3
      end

      it "returns existing tags" do
        result.should include @tag1
      end

      it "returns tags with the correct names" do
        result.map{ |tag| tag.name }.should match_array ["TAG1", "Tag2", "tag3"]
      end
    end
  end
end