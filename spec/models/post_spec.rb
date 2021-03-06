require 'spec_helper'

describe Post do
  let(:post){ build(:post) }

  it "is valid with valid attributes" do
    post.should be_valid
  end

  it "is invalid without a author" do
    post.author = nil
    post.should be_invalid
  end

  describe "#title" do
    it "is required" do
      post.title = nil
      post.should be_invalid
    end

    it "cannot be blank" do
      post.title = " "
      post.should be_invalid
    end

    it "cannot be longer than 255 characters" do
      post.title = "a" * 255
      post.should be_valid
      post.title = "a" * 256
      post.should be_invalid
    end

    it "is trimmed when saved" do
      post.title = "  Some title "
      post.save!
      post.title.should == "Some title"
    end
  end

  describe "#formatted_created_at" do
    it "returns a formatted version of the created date" do
      post.created_at = Date.new(2009, 2, 3)
      post.formatted_created_at.should == "3rd February 2009"
    end
  end

  describe "#tag_names=" do
    it "sets a tag list" do
      post.tag_names = "tag1, tag2"
      post.save!
      post.reload.tags.map{ |tag| tag.name }.should match_array ["tag1", "tag2"]
    end

    it "removes and updates tags from an existing tag list" do
      post.tag_names = "tag1, tag2"
      post.save!
      post.reload.tag_names = "tag2, tag3"
      post.save!
      post.reload.tags.map{ |tag| tag.name }.should match_array ["tag2", "tag3"]
    end

    it "is invalid when passed an invalid tag" do
      post.save!
      post.tag_names = "a" * 51 + ", tag2"
      post.should be_invalid
    end

    it "sets both existing and new tags correctly" do
      @tag1 = Tag.create(name: "tag1")

      post.tag_names = " tag2,  TAG1, Tag1, Tag2,  tag 3  "
      post.save!
      post.tags.reload
      post.tags.should include @tag1
      post.tags.length.should == 3
      post.tags.map { |tag| tag.name }.should match_array ["tag1", "tag2", "tag 3"]
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
      post.teachers.should == [post.author]
      post.students.should be_empty
    end

    it "adds a student tag if the author is a student" do
      post.author = create(:student)
      post.initialize_tags
      post.students.should == [post.author]
      post.teachers.should be_empty
    end

    it "adds a student tag if the author is a guardian" do
      student = create(:student)
      post.author = create(:guardian, students: [student])
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
      post.author = create(:student)
      post.initialize_observations
      post.student_observations.should be_empty
    end

    it "does nothing if the author is a guardian" do
      post.author = create(:guardian)
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
        post.student_observations.map{ |obs| obs.student }.should match_array [student1, student2]
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
      before { post.author = student }

      it "automatically sets the self tag" do
        post.students = [other_student]
        post.teachers = []
        post.save!
        post.students.should match_array [other_student, student]
        post.teachers.should be_empty
      end

      it "does not duplicate the student tag if present" do
        post.students = [student]
        post.save!
        post.students = [student, other_student]
        post.save!
        post.students.should match_array [student, other_student]
      end
    end

    context "if posted by a guardian" do
      let(:guardian){ create(:guardian, students: [student, other_student]) }
      before { post.author = guardian }

      let(:third_student){ create(:student) }

      it "is valid if at least one of the guardian's students are tagged" do
        post.students = [third_student, other_student]
        post.should be_valid
        post.save!
        post.students.should match_array [third_student, other_student]
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
      post.author = create(:student)
      post.save!
      post.visible_to_students.should == true
      post.visible_to_guardians.should == true
    end

    it "must be visible to guardians if created by a guardians" do
      post.author = create(:guardian)
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

      it "does not create an observation with html tags but no content" do
        post.student_observations_attributes = {
          '0' => { 'student_id' => student.id, 'content' => "   <p>   <br />   <br />   </p>" }
        }
        post.save!
        post.student_observations.should be_empty
      end

      it "creates an observation with only an image tag" do
        post.student_observations_attributes = {
          '0' => { 'student_id' => student.id, 'content' => "<img title=\"blahblah\" src=\"http://blahblah.com\">" }
        }
        post.save!
        post.student_observations.first.content.should == "<img title=\"blahblah\" src=\"http://blahblah.com\">"
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
        post.student_observations.map{ |x| x.content }.should match_array ["Some changed content", "New content"]
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
  end

  describe "##readable_by_guardian" do
    it "returns posts tagged with the guardians students and visible to the guardian" do
      student = create(:student)
      other_student = create(:student)
      third_student = create(:student)

      guardian = create(:guardian, students: [student, other_student])

      post1 = create(:post)
      post2 = create(:post, students: [third_student], author: student, visible_to_guardians: true)
      post3 = create(:post, students: [student, other_student, third_student])
      post4 = create(:post, students: [other_student], visible_to_guardians: true)
      post5 = create(:post, students: [student])
      post6 = create(:post, students: [third_student], visible_to_guardians: true)

      Post.readable_by_guardian(guardian).should match_array [post2, post4]
    end
  end

  describe "comments" do
    it "should be ordered by the oldest first" do
      post.save!
      comment1 = create(:comment, post: post, created_at: 1.day.ago)
      comment2 = create(:comment, post: post, created_at: Time.now)
      comment3 = create(:comment, post: post, created_at: 2.days.ago)
      comment4 = create(:comment, post: post, created_at: 1.hour.ago)

      post.comments.should == [comment3, comment1, comment4, comment2]
    end
  end

  describe "#restriction_message" do
    subject{ post.restriction_message }

    context "when unrestricted" do
      before do
        post.visible_to_guardians = true
        post.visible_to_students = true
      end

      it { should be_nil }
    end

    context "when restricted to students" do
      before{ post.visible_to_guardians = true }

      it { should == "Not visible to students" }
    end

    context "when restricted to guardians" do
      before{ post.visible_to_students = true }

      it { should == "Not visible to guardians" }
    end

    context "when restricted to students and guardians" do
      it { should == "Not visible to guardians or students" }
    end
  end

  describe "sanitization of content" do
    let(:object){ post }
    it_behaves_like "an object with sanitized content"
  end

  describe "##filter_by_params" do
    before do
      @student1 = create(:student)
      @student2 = create(:student)
      @student3 = create(:student)

      @group1 = create(:group)
      @group1.students << [@student1, @student2]
      @group2 = create(:group)
      @group2.students << @student3

      @tag1 = create(:tag)
      @tag2 = create(:tag)
      @tag3 = create(:tag)
      @tag4 = create(:tag)

      @post1 = create(:post, title: "Some title", students: [@student1])
      @post1.created_at = Date.new(2010, 2, 5)
      @post1.tags = [@tag1, @tag2]
      @post1.save!

      @post2 = create(:post, title: "Second post")
      @post2.created_at = Date.new(2010, 1, 20)
      @post2.save!

      @post3 = create(:post, title: "Some other title", students: [@student1, @student2])
      @post3.created_at = Date.new(2011, 5, 10)
      @post3.tags = [@tag2]
      @post3.save!

      @post4 = create(:post, title: "Last post", students: [@student2])
      @post4.created_at = Date.new(2010, 10, 15)
      @post4.tags = [@tag2, @tag3]
      @post4.save!
      @tag
    end

    it "returns all posts with no parameters" do
      Post.filter_by_params({}).should match_array [@post1, @post2, @post3, @post4]
    end

    describe "search" do
      it "searches for a post if the search parameter is present" do
        Post.filter_by_params({search: "some"}).should match_array [@post1, @post3]
      end

      it "returns all posts with an empty search parameter" do
        Post.filter_by_params({search: "   "}).should match_array [@post1, @post2, @post3, @post4]
      end

      it "returns no posts with an unmatched query" do
        Post.filter_by_params({search: "unmatched query"}).should be_empty
      end
    end

    describe "tagged student" do
      it "filters posts by a tagged student" do
        Post.filter_by_params({student: @student1.id}).should match_array [@post1, @post3]
      end

      it "does not filter students if the student parameter is 0" do
        Post.filter_by_params({student: 0}).should match_array [@post1, @post2, @post3, @post4]
      end

      it "returns no posts if a student is selected with no tagged posts" do
        Post.filter_by_params({student: @student3.id}).should be_empty
      end

      it "combines a search and a student filter" do
        Post.filter_by_params({student: @student1.id, search: "other"}).should == [@post3]
      end
    end

    describe "groups" do
      it "returns posts with tagged students that belong to the group when a group param is present" do
        Post.filter_by_params({group: @group1.id}).should match_array [@post1, @post3, @post4]
      end

      it "does not filter groups if the group parameter is 0" do
        Post.filter_by_params({group: 0}).should match_array [@post1, @post2, @post3, @post4]
      end

      it "returns no posts when a group with students that are tagged in no posts is passed" do
        Post.filter_by_params({group: @group2.id}).should be_empty
      end

      it "filters groups and students within a group" do
        Post.filter_by_params({group: @group1.id, student: @student2.id}).should match_array [@post3, @post4]
      end

      it "returns nothing if passed a group and a student not in that group" do
        Post.filter_by_params({group: @group1.id, student: @student3.id}).should be_empty
      end

      it "filters groups, students and searches together" do
        Post.filter_by_params({search: "pos", group: @group1.id, student: @student2.id}).should == [@post4]
      end
    end

    describe "tags" do
      it "returns posts filtered by the tag" do
        Post.filter_by_params({tag: @tag2.id}).should match_array [@post1, @post3, @post4]
      end

      it "does not filter groups if the tag parameter is 0" do
        Post.filter_by_params({tag: 0}).should match_array [@post1, @post2, @post3, @post4]
      end

      it "returns no posts for a tag with no posts" do
        Post.filter_by_params({tag: @tag4.id}).should be_empty
      end

      it "filters tags and a search" do
        Post.filter_by_params({tag: @tag2.id, search: "tit"}).should match_array [@post1, @post3]
      end

      it "filters groups, students, tags and searches together" do
        Post.filter_by_params({search: "pos", group: @group1.id, student: @student2.id, tag: @tag3.id}).should == [@post4]
        Post.filter_by_params({search: "pos", group: @group1.id, student: @student2.id, tag: @tag1.id}).should be_empty
      end
    end

    describe "date" do
      it "returns posts filtered by the from date" do
        Post.filter_by_params({dateFrom: "05-05-2010"}).should match_array [@post3, @post4]
      end

      it "returns posts filtered by the to date" do
        Post.filter_by_params({dateTo: "05-05-2010"}).should match_array [@post1, @post2]
      end

      it "returns posts filtered by the from date and to date" do
        Post.filter_by_params({dateFrom: "05-05-2010", dateTo: "12-12-2010"}).should == [@post4]
      end

      it "returns posts from a single day" do
        Post.filter_by_params({dateFrom: "05-02-2010", dateTo: "05-02-2010"}).should == [@post1]
      end

      it "filters tags and dates" do
        Post.filter_by_params({dateFrom: "05-05-2010", tag: @tag3.id}).should == [@post4]
      end

      it "filters search and dates" do
        Post.filter_by_params({dateTo: "05-05-2010", search: "post"}).should == [@post2]
      end
    end

    it "filters everything together" do
      Post.filter_by_params({
        dateFrom: "01-02-2010",
        dateTo: "30-12-2010",
        search: "last",
        group: @group1.id,
        student: @student2.id,
        tag: @tag2.id
      }).should == [@post4]

      # Check each filter, to make sure if it is changed, we get a blank result
      Post.filter_by_params({
        dateFrom: "01-12-2010",
        dateTo: "30-12-2010",
        search: "last",
        group: @group1.id,
        student: @student2.id,
        tag: @tag2.id
      }).should be_empty

      Post.filter_by_params({
        dateFrom: "01-02-2010",
        dateTo: "01-04-2010",
        search: "last",
        group: @group1.id,
        student: @student2.id,
        tag: @tag2.id
      }).should be_empty

      Post.filter_by_params({
        dateFrom: "01-02-2010",
        dateTo: "30-12-2010",
        search: "title",
        group: @group1.id,
        student: @student2.id,
        tag: @tag2.id
      }).should be_empty

      Post.filter_by_params({
        dateFrom: "01-02-2010",
        dateTo: "30-12-2010",
        search: "last",
        group: @group2.id,
        student: @student2.id,
        tag: @tag2.id
      }).should be_empty

      Post.filter_by_params({
        dateFrom: "01-02-2010",
        dateTo: "30-12-2010",
        search: "last",
        group: @group1.id,
        student: @student1.id,
        tag: @tag2.id
      }).should be_empty

      Post.filter_by_params({
        dateFrom: "01-02-2010",
        dateTo: "30-12-2010",
        search: "last",
        group: @group1.id,
        student: @student2.id,
        tag: @tag1.id
      }).should be_empty
    end
  end
end