require 'spec_helper'

describe Student do
  let(:profile){ build(:student) }
  let(:profile_type){ :student }
  let(:profile_class){ Student }

  it_behaves_like "a profile"

  it "cannot have a bloodgroup longer than 15 characters" do
    profile.bloodgroup = "a" * 15
    profile.should be_valid
    profile.bloodgroup = "a" * 16
    profile.should be_invalid
  end

  describe "#formatted_birthday" do
    it "returns nil if the birthday is empty" do
      profile.formatted_birthday.should be_nil
    end

    it "returns the formatted birthday if present" do
      profile.birthday = Date.new(1955, 7, 12)
      profile.formatted_birthday.should == '12-07-1955'
    end
  end

  describe "#formatted_birthday=" do
    it "sets the birthday given a string" do
      profile.formatted_birthday = "12-10-1980"
      profile.birthday.should == Date.new(1980, 10, 12)
    end

    it "sets the birthday to nil if invalid" do
      profile.formatted_birthday = "asdf"
      profile.birthday.should be_nil
    end

    it "sets the birthday to nil if blank" do
      profile.formatted_birthday = ""
      profile.birthday.should be_nil
    end

    it "sets the birthday to nil if nil" do
      profile.formatted_birthday = nil
      profile.birthday.should be_nil
    end
  end

  describe "#age" do
    it "returns nil if the birthday is empty" do
      profile.age.should be_nil
    end

    it "returns the age if the profile is present" do
      profile.birthday = Date.new(1955, 7, 12)
      Date.stub(:now).and_return(Date.new(2013,1,1))
      profile.age.should == 57
    end
  end

  describe "#birthday_with_age" do
    it "returns nil if the birthday is empty" do
      profile.birthday_with_age.should be_nil
    end

    it "returns the date of birth and age if the profile is present" do
      profile.birthday = Date.new(1955, 7, 12)
      Date.stub(:now).and_return(Date.new(2013,1,1))
      profile.birthday_with_age.should == "12-07-1955 (57 yrs)"
    end
  end

  describe "on destruction" do
    before{ profile.save! }

    it "destroys a guardian without other students" do
      create(:guardian, students: [profile])
      expect { profile.destroy }.to change { Guardian.count }.by(-1)
    end

    it "removes itself from a guardian with other students" do
      guardian = create(:guardian)
      guardian.students << profile
      guardian.students.exists?(profile).should == true
      profile.destroy
      guardian.students.exists?(profile).should == false
    end

    it "does not destroy a guardian with other students" do
      guardian = create(:guardian)
      guardian.students << profile
      expect { profile.destroy }.to change { Guardian.count }.by(0)
    end

    it "destroys any student observations" do
      create(:student_observation, student: profile)
      expect { profile.destroy }.to change { StudentObservation.count }.by(-1)
    end
  end

  describe "#name_with_type" do
    it "returns the full name along with the profile type" do
      profile.first_name = "Rahul"
      profile.last_name = "Sekhar"
      profile.name_with_type.should == "Rahul Sekhar (student)"
    end
  end

  describe "#toggle_archive" do
    let(:guardian1){ create(:guardian_with_user, students: [profile]) }
    let(:guardian2){ create(:guardian_with_user, students: [profile, create(:student)]) }
    let(:guardian3){ create(:guardian_with_user, students: [profile, create(:student, archived: true)]) }
    
    context "if not archived" do
      before do 
        profile.email = "test@mail.com"
        profile.save!
      end

      it "should be archived" do
        profile.toggle_archive
        profile.reload.archived.should == true
      end

      it "should deactivate the user" do
        profile.user.should_receive(:deactivate)
        profile.toggle_archive
      end

      it "removes all mentors from the student" do
        profile.mentors = [create(:teacher), create(:teacher)]
        profile.toggle_archive
        profile.reload.mentors.should be_empty
      end

      it "should deactivate any guardians that are archived" do
        guardian1.reset_password
        guardian2.reset_password
        guardian3.reset_password
        profile.toggle_archive
        guardian1.reload.should_not be_active
        guardian2.reload.should be_active
        guardian3.reload.should_not be_active
      end
    end

    context "if archived" do
      before do
        profile.archived = true
        profile.save!
      end

      it "should not be archived" do
        profile.toggle_archive
        profile.reload.archived.should == false
      end

      it "should not bother with guardians" do
        guardian1
        guardian2.reset_password
        guardian3
        profile.toggle_archive
        guardian1.reload.should_not be_active
        guardian2.reload.should be_active
        guardian3.reload.should_not be_active
      end
    end

    context "with no user" do
      it "should work" do
        profile.save!
        profile.toggle_archive
        profile.archived.should == true
        profile.toggle_archive
        profile.archived.should == false
      end
    end
  end

  describe "#remaining_groups" do
    it "returns an empty array when no groups exist" do
      profile.remaining_groups.should be_empty
    end

    context "when some groups exist" do
      before do
        @group1 = create(:group, name: "Group 1")
        @group2 = create(:group, name: "Group 2")
        @group3 = create(:group, name: "Group 3")
      end

      it "returns all groups when the student has no groups" do
        profile.remaining_groups.should =~ [@group1, @group2, @group3]
      end

      it "returns an empty array when the student has all existing groups" do
        profile.groups = [@group1, @group2, @group3]
        profile.remaining_groups.should be_empty
      end

      it "returns only groups that are not added to the student already" do
        profile.groups = [@group2]
        profile.remaining_groups.should =~ [@group1, @group3]
      end
    end
  end

  describe "#remaining_teachers" do
    it "returns an empty array when no teachers exist" do
      profile.remaining_teachers.should be_empty
    end

    context "when some teachers exist" do
      before do
        @teacher1 = create(:teacher)
        @teacher2 = create(:teacher)
        @teacher3 = create(:teacher)
        @teacher4 = create(:teacher, archived: true)
      end

      it "returns all unarchived teachers when the student has no mentors" do
        profile.remaining_teachers.should =~ [@teacher1, @teacher2, @teacher3]
      end

      it "returns an empty array when the student has all existing mentors" do
        profile.mentors = [@teacher1, @teacher2, @teacher3]
        profile.remaining_teachers.should be_empty
      end

      it "returns only teachers that are not added to the student already" do
        profile.mentors = [@teacher2]
        profile.remaining_teachers.should =~ [@teacher1, @teacher3]
      end
    end
  end

  describe "##filter_group" do
    before do
      @student1 = create(:student)
      @student2 = create(:student)
      @student3 = create(:student)
      @group1 = create(:group)
      @group1.students << [@student1, @student2]
      @group2 = create(:group)
      @group2.students << [@student2, @student3]
      @group3 = create(:group)
    end

    it "returns all students when nil is passed" do
      Student.filter_group(nil).should =~ [@student1, @student2, @student3]
    end

    it "returns all students when 0 is passed" do
      Student.filter_group(0).should =~ [@student1, @student2, @student3]
    end

    it "returns students within that group when a group id is passed" do
      Student.filter_group(@group1.id).should == [@student1, @student2]
    end

    it "returns no students when a group with no students is passed" do
      Student.filter_group(@group3.id).should be_empty
    end
  end
  

  describe "permissions:" do
    before do 
      profile.email = "test@mail.com"
      profile.save!
    end
    let(:ability){ Ability.new(profile.user) }

    describe "posts:" do
      it "can create posts" do
        ability.should be_able_to :create, Post
      end

      it "can manage its own posts" do
        own_post = create(:post, author: profile)
        ability.should be_able_to :manage, own_post
      end

      context "when not tagged in the post" do
        it "cannot read, edit or destroy posts created by a teacher" do
          post = create(:post, author: create(:teacher) )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end

        it "cannot read, edit or destroy posts created by another student" do
          post = create(:post, author: create(:student) )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end

        it "cannot read, edit or destroy posts created by a guardian" do
          post = create(:post, author: create(:guardian) )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end
      end

      context "when tagged in the post" do
        let(:post){ create(:post, students: [profile]) }
        
        context "when it has view permissions" do
          before do 
            post.visible_to_students = true
            post.save
          end

          it "can read the post" do
            ability.should be_able_to :read, post
          end

          it "cannot manage the post" do
            ability.should_not be_able_to :update, post
            ability.should_not be_able_to :destroy, post
          end
        end

        context "when it does not have view permissions" do
          before do 
            post.visible_to_students = false
            post.save
          end

          it "cannot read, edit or destroy the post" do
            ability.should_not be_able_to :read, post
            ability.should_not be_able_to :update, post
            ability.should_not be_able_to :destroy, post
          end
        end
      end
    end

    describe "comments:" do
      it "can create comments" do
        ability.should be_able_to :create, Comment
      end

      it "can manage its own comments" do
        own_comment = create(:comment, author: profile)
        ability.should be_able_to :manage, own_comment
      end

      it "can only read comments created by a teacher" do
        comment = create(:comment, author: create(:teacher) )
        ability.should be_able_to :read, comment
        ability.should_not be_able_to :update, comment
        ability.should_not be_able_to :destroy, comment
      end

      it "can only read comments created by another student" do
        comment = create(:comment, author: create(:student) )
        ability.should be_able_to :read, comment
        ability.should_not be_able_to :update, comment
        ability.should_not be_able_to :destroy, comment
      end

      it "can only read comments created by a guardian" do
        comment = create(:comment, author: create(:guardian) )
        ability.should be_able_to :read, comment
        ability.should_not be_able_to :update, comment
        ability.should_not be_able_to :destroy, comment
      end
    end

    describe "profiles:" do
      it "can view profiles" do
        ability.should be_able_to :read, Student
        ability.should be_able_to :read, Teacher
        ability.should be_able_to :read, Guardian
      end

      it "cannot edit profiles" do
        ability.should_not be_able_to :update, create(:student)
        ability.should_not be_able_to :update, create(:teacher)
        ability.should_not be_able_to :update, create(:guardian)
      end

      it "can edit its own profile" do
        ability.should be_able_to :update, profile
      end

      it "cannot create profiles" do
        ability.should_not be_able_to :create, Student
        ability.should_not be_able_to :create, Teacher
        ability.should_not be_able_to :create, Guardian
      end

      it "cannot administrate profiles" do
        ability.should_not be_able_to :administrate, Student
        ability.should_not be_able_to :create, Student
        ability.should_not be_able_to :reset, Student
        ability.should_not be_able_to :archive, Student
        ability.should_not be_able_to :destroy, Student
        ability.should_not be_able_to :add_mentor, Student
        ability.should_not be_able_to :remove_mentor, Student
        ability.should_not be_able_to :add_group, Student
        ability.should_not be_able_to :remove_group, Student

        ability.should_not be_able_to :administrate, Teacher
        ability.should_not be_able_to :reset, Teacher
        ability.should_not be_able_to :archive, Teacher
        ability.should_not be_able_to :destroy, Teacher
        ability.should_not be_able_to :add_mentee, Teacher
        ability.should_not be_able_to :remove_mentee, Teacher

        ability.should_not be_able_to :administrate, Guardian
        ability.should_not be_able_to :reset, Guardian
        ability.should_not be_able_to :destroy, Guardian
      end
    end

    describe "groups:" do
      it "can view groups" do
        ability.should be_able_to :read, Group
      end

      it "cannot create, edit and delete groups" do
        ability.should_not be_able_to :create, Group
        ability.should_not be_able_to :update, Group
        ability.should_not be_able_to :delete, Group
      end
    end
  end
end