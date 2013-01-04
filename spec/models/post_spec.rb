require 'spec_helper'

describe Post do
  let(:post){ build(:post) }

  it "is valid with valid attributes" do
    post.should be_valid
  end

  it "is invalid without a title" do
    post.title = nil
    post.should be_invalid
  end

  it "is invalid without a user (author)" do
    post.user = nil
    post.should be_invalid
  end

  describe "#formatted_created_at" do
    it "returns a formatted version of the created date" do
      post.created_at = Date.new(2009, 2, 3)
      post.formatted_created_at.should == "3rd February 2009"
    end
  end

  describe "#author_name" do
    it "returns the associated users name" do
      post.user.stub(:name).and_return("Some Name")
      post.author_name.should eq("Some Name")
    end
  end

  describe "#author_profile" do
    it "returns the associated users profile" do
      post.author_profile.should eq(post.user.profile)
    end
  end

  describe "#tag_names=" do
    it "creates the tags that do not exist" do
      post.tag_names = "Tag1, Tag2"
      expect{ post.save! }.to change{ Tag.count }.by(2)
    end

    it "creates tags with the correct names" do
      post.tag_names = "Tag1, Tag2"
      post.tags.map{ |tag| tag.name }.should =~ ["Tag1", "Tag2"]
    end

    it "is invalid with an invalid tag name" do
      post.tag_names = "Tag1, #{"a" * 61}"
      post.should be_invalid
    end

    it "uses tags that already exist" do
      create(:tag, name: "Tag1")
      post.tag_names = "Tag1, Tag2"
      expect{ post.save! }.to change{ Tag.count }.by(1)
      post.tags.map{ |tag| tag.name }.should =~ ["Tag1", "Tag2"]
    end

    it "checks existing tags case insensitively" do
      create(:tag, name: "tag1")
      post.tag_names = "Tag1, Tag2"
      expect{ post.save! }.to change{ Tag.count }.by(1)
      post.tags.map{ |tag| tag.name }.should =~ ["tag1", "Tag2"]
    end

    it "removes duplicates" do
      create(:tag, name: "tag1")
      post.tag_names = "Tag1, Tag2, tag1, tag2"
      expect{ post.save! }.to change{ Tag.count }.by(1)
      post.tags.map{ |tag| tag.name }.should =~ ["tag1", "Tag2"]
    end

    it "removes blank items" do
      post.tag_names = "tag1,  , tag2"
      expect{ post.save! }.to change{ Tag.count }.by(2)
      post.tags.map{ |tag| tag.name }.should =~ ["tag1", "tag2"]
    end

    it "updates an existing tag list" do
      post.tag_names = "tag1, tag2"
      post.save!
      
      post.tag_names = "tag2, tag3"
      expect{ post.save! }.to change{ Tag.count }.by(1)
      post.tags.map{ |tag| tag.name }.should =~ ["tag2", "tag3"]
    end
  end

  describe "#tag_names" do
    it "returns a blank string when no tags exist" do
      post.tags.clear
      post.tag_names.should == ""
    end

    it "returns a comma separated array of tags, ordered alphabetically" do
      post.tags << Tag.new(name: "some tag")
      post.tags << Tag.new(name: "other tag")
      post.tags << Tag.new(name: "other bag")
      post.tags << Tag.new(name: "fourth tag")
      post.tag_names.should == "fourth tag, other bag, other tag, some tag"
    end
  end

  describe "#initialize_tag" do
    it "adds a teacher tag if the author is a teacher" do
      post.initialize_tag
      post.teachers.should == [post.author_profile]
      post.students.should be_empty
    end

    it "adds a student tag if the author is a student" do
      post.user = create(:student).user
      post.initialize_tag
      post.students.should == [post.author_profile]
      post.teachers.should be_empty
    end

    it "adds a student tag if the author is a guardian" do
      student = create(:student)
      post.user = create(:guardian, student: student).user
      post.initialize_tag
      post.students.should == [student]
      post.teachers.should be_empty
    end
  end

  describe "student and teacher tags" do
    let(:student){ create(:student) }
    let(:other_student){ create(:student) }

    it "must include the self tag if posted by a student" do
      post.user = student.user
      post.students = [other_student]
      post.teachers = []
      post.save!
      post.students.should =~ [other_student, student]
      post.teachers.should be_empty
    end

    it "must include the self tag if posted by a guardian" do
      guardian = create(:guardian, student: student)
      post.user = guardian.user
      post.students = [other_student]
      post.teachers = []
      post.save!
      post.students.should =~ [other_student, student]
      post.teachers.should be_empty
    end

    it "do not need to include the self tag if posted by a teacher" do
      post.students = [other_student]
      post.teachers = []
      post.save!
      post.students.should == [other_student]
      post.teachers.should be_empty
    end
  end

  describe "permissions" do
    it "must be visible to both guardians and students if created by a student" do
      post.user = create(:student).user
      post.save
      post.visible_to_students.should == true
      post.visible_to_guardians.should == true
    end

    it "must be visible to guardiansif created by a guardians" do
      post.user = create(:guardian).user
      post.save
      post.visible_to_students.should == false
      post.visible_to_guardians.should == true
    end
  end
end