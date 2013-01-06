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

  describe "#initialize_tags" do
    it "adds a teacher tag if the author is a teacher" do
      post.initialize_tags
      post.teachers.should == [post.author_profile]
      post.students.should be_empty
    end

    it "adds a student tag if the author is a student" do
      post.user = create(:student).user
      post.initialize_tags
      post.students.should == [post.author_profile]
      post.teachers.should be_empty
    end

    it "adds a student tag if the author is a guardian" do
      student = create(:student)
      post.user = create(:guardian, students: [student]).user
      post.initialize_tags
      post.students.should == [student]
      post.teachers.should be_empty
    end
  end

  describe "#initialize_observations" do
    let(:student1){ create(:student) }
    let(:student2){ create(:student) }

    before { post.students = [student1, student2] }

    it "does nothing if the author is a student" do
      post.user = create(:student).user
      post.initialize_observations
      post.student_observations.should be_empty
    end

    it "does nothing if the author is a guardian" do
      post.user = create(:guardian).user
      post.initialize_observations
      post.student_observations.should be_empty
    end

    context "if the author is a teacher" do
      it "does nothing if there are no students" do
        post.students = []
        post.initialize_observations
        post.student_observations.should be_empty
      end

      it "initializes observations" do
        post.initialize_observations
        post.student_observations.length.should == 2
      end

      it "initializes observations for the correct students" do
        post.initialize_observations
        post.student_observations.map{ |obs| obs.student }.should =~ [student1, student2]
      end

      it "does not initialize observations that are already present" do
        create(:student_observation, post: post, student: student2)
        post.reload.initialize_observations
        post.student_observations.length.should == 2
        post.student_observations.find{ |obs| obs.student == student1 }.should be_new_record
        post.student_observations.find{ |obs| obs.student == student2 }.should_not be_new_record
      end
    end
  end

  describe "student and teacher tags" do
    let(:student){ create(:student) }
    let(:other_student){ create(:student) }

    context "if posted by a student" do
      before { post.user = student.user }
      
      it "automatically sets the self tag" do
        post.students = [other_student]
        post.teachers = []
        post.save!
        post.students.should =~ [other_student, student]
        post.teachers.should be_empty
      end

      it "does not duplicate the student tag if present" do
        post.students = [student]
        post.save!
        post.students = [student, other_student]
        post.save!
        post.students.should =~ [student, other_student]
      end
    end

    context "if posted by a guardian" do
      let(:guardian){ create(:guardian, students: [student, other_student]) }
      before { post.user = guardian.user }

      let(:third_student){ create(:student) }

      it "is valid if at least one of the guardian's students are tagged" do
        post.students = [third_student, other_student]
        post.should be_valid
        post.save!
        post.students.should =~ [third_student, other_student]
      end

      it "is invalid if none of the guardian's students are tagged" do
        post.students = [third_student]
        post.should be_invalid
      end
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
      post.save!
      post.visible_to_students.should == true
      post.visible_to_guardians.should == true
    end

    it "must be visible to guardians if created by a guardians" do
      post.user = create(:guardian).user
      post.initialize_tags
      post.save!
      post.visible_to_students.should == false
      post.visible_to_guardians.should == true
    end
  end

  describe "on destruction" do
    it "destroys any comments" do
      post.save!
      create(:comment, post: post)
      expect { post.destroy }.to change { Comment.count }.by(-1)
    end

    it "destroys any student observations" do
      student = create(:student)
      post.students << student
      post.save!
      create(:student_observation, post: post, student: student)
      post.reload.save!
      expect { post.destroy }.to change { StudentObservation.count }.by(-1)
    end
  end

  describe "#student_observations_attributes" do
    context "with a tagged student" do
      let(:student){ create(:student) }
      before{ post.students << student }
      
      it "creates a student observation when no id is passed" do
        post.student_observations_attributes = {
          '0' => { 'student_id' => student.id, 'content' => "Some content" }
        }
        post.save!
        obs = post.student_observations.first
        obs.content.should == "Some content"
        obs.student.should == student
      end

      it "does not create a student observation with no content" do
        post.student_observations_attributes = {
          '0' => { 'student_id' => student.id, 'content' => " " }
        }
        post.save!
        post.student_observations.should be_empty
      end

      it "edits an existing student observation when the id is passed" do
        obs = create(:student_observation, post: post, student: student)
        post.reload.student_observations_attributes = {
          '0' => { 'id' => obs.id, 'content' => "Some changed content" }
        }
        post.save!
        post.student_observations.first.should == obs
        post.student_observations.first.content.should == "Some changed content"
        obs.reload.content.should == "Some changed content"
      end

      it "removes a student observation when blank content is passed" do
        obs = create(:student_observation, post: post, student: student)
        post.reload.student_observations_attributes = {
          '0' => { 'id' => obs.id, 'content' => "" }
        }
        post.save!
        post.reload.student_observations.should be_empty
        StudentObservation.exists?(obs).should == false
      end

      it "can add edit and remove mutiple observations" do
        student1 = create(:student)
        student2 = create(:student)
        student3 = create(:student)
        post.students << [student1, student2, student3]
        obs = create(:student_observation, post: post, student: student)
        obs1 = create(:student_observation, post: post, student: student1)

        post.reload.student_observations_attributes = {
          '0' => { 'id' => obs.id, 'content' => "Some changed content" },
          '1' => { 'id' => obs1.id, 'content' => "" },
          '2' => { 'content' => "New content", student_id: student2.id },
          '3' => { 'content' => " ", student_id: student3.id }
        }

        post.save!

        post.student_observations.length.should == 2
        post.student_observations.include?(obs).should == true
        post.student_observations.include?(obs1).should == false
        StudentObservation.exists?(obs1).should == false
        post.student_observations.map{ |x| x.content }.should =~ ["Some changed content", "New content"]
      end
    end

    context "with an untagged student" do
      let(:untagged_student){ create(:student) }

      it "does not save a new observation" do
        post.student_observations_attributes = {
          '0' => { 'student_id' => untagged_student.id, 'content' => "Some content" }
        }
        post.save!
        post.student_observations.should be_empty
      end

      it "deletes an existing observation" do
        post.save!
        create(:student_observation, post: post, student: untagged_student)
        post.reload.save!
        post.student_observations.should be_empty
      end
    end

    describe "##readable_by_guardian" do
      it "returns posts tagged with the guardians students and visible to the guardian" do
        student = create(:student)
        other_student = create(:student)
        third_student = create(:student)

        guardian = create(:guardian, students: [student, other_student])

        post1 = create(:post)
        post2 = create(:post, students: [third_student], user: student.user, visible_to_guardians: true)
        post3 = create(:post, students: [student, other_student, third_student])
        post4 = create(:post, students: [other_student], visible_to_guardians: true)
        post5 = create(:post, students: [student])
        post6 = create(:post, students: [third_student], visible_to_guardians: true)

        Post.readable_by_guardian(guardian).should =~ [post2, post4]
      end
    end

    it "filters out observations with html tags but no content"

    it "does not filter out image tags"
  end
end