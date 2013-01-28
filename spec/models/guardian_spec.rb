require 'spec_helper'

describe Guardian do
  let(:profile){ build(:guardian) }
  let(:profile_type){ :guardian }
  let(:profile_class){ Guardian }

  it_behaves_like "a profile"

  describe "#name_with_type" do
    context "with one student" do
      it "returns the full name along with the profile type and the associated student" do
        profile.first_name = "Rahul"
        profile.last_name = "Sekhar"

        student = profile.students.first
        student.first_name = "Roly"
        student.last_name = "Dog"

        profile.name_with_type.should == "Rahul Sekhar (guardian of Roly Dog)"
      end  
    end

    context "with multiple students" do
      it "returns the full name along with the profile type and all the associated students names" do
        profile.first_name = "Rahul"
        profile.last_name = "Sekhar"

        profile.save

        student = profile.students.first
        student.first_name = "Roly"
        student.last_name = "Dog"
        student.save
        profile.students << create(:student, first_name: "John", last_name: "Doe")
        profile.students << create(:student, first_name: "Lucky", last_name: "Dog")

        profile.name_with_type.should == "Rahul Sekhar (guardian of John, Lucky, and Roly)"
      end  
    end
  end

  describe "#students_as_sentence" do
    subject{ profile.students_as_sentence }
    before do 
      profile.students = [create(:student, first_name: "Roly", last_name: "Sekhar")]
      profile.save!
    end
    
    context "with one student" do
      it { should == "Roly" }
    end

    context "with two students" do
      before{ profile.students << [create(:student, first_name: "Lucky", last_name: "Sekhar")] }

      it { should == "Lucky and Roly" }
    end

    context "with three students" do
      before do 
        profile.students << [create(:student, first_name: "Lucky", last_name: "Sekhar")]
        profile.students << [create(:student, first_name: "Jumble", last_name: "Sekhar")]
      end

      it { should == "Jumble, Lucky, and Roly" }
    end
  end

  describe "#archived" do
    it "returns true if all the students are archived" do
      profile.students.first.archived = true
      profile.students << create(:student, archived: true)
      profile.archived.should == true
    end

    it "returns false if any of the students are not archived" do
      profile.students.first.archived = false
      profile.students << create(:student, archived: true)
      profile.archived.should == false
    end

    it "returns false if all of the students are not archived" do
      profile.students.first.archived = false
      profile.students << create(:student, archived: false)
      profile.archived.should == false
    end
  end

  describe "permissions:" do
    let(:student1){ create(:student) }
    let(:student2){ create(:student) }

    let(:profile){ create(:guardian, email: "test@mail.com", students: [student1, student2]) }

    let(:ability){ Ability.new(profile.user) }

    describe "posts:" do
      it "can create posts" do
        ability.should be_able_to :create, Post
      end

      it "can read, update and destroy its own posts" do
        own_post = create(:post, author: profile)
        ability.should be_able_to :read, own_post
        ability.should be_able_to :update, own_post
        ability.should be_able_to :destroy, own_post
      end

      context "when its students are not tagged in the post" do
        it "cannot read, edit or destroy posts created by a teacher" do
          post = create(:post, author: create(:teacher) )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end

        it "cannot read, edit or destroy posts created by a student" do
          post = create(:post, author: create(:student) )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end

        it "cannot read, edit or destroy posts created by another guardian" do
          post = create(:post, author: create(:guardian) )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end
      end

      context "when either of its students are tagged in the post" do
        let(:post){ create(:post, students: [student1]) }
        
        context "when it has view permissions" do
          before do 
            post.visible_to_guardians = true
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

      it "can edit only its own students profile" do
        ability.should be_able_to :update, student1
        ability.should be_able_to :update, student2
        ability.should_not be_able_to :update, create(:student)
      end

      it "can edit a guardian shared by any of its students profile" do
        guardian1 = create(:guardian, students: [student1])
        guardian2 = create(:guardian, students: [student2])
        guardian3 = create(:guardian)

        ability.should be_able_to :update, guardian1
        ability.should be_able_to :update, guardian2
        ability.should_not be_able_to :update, guardian3
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