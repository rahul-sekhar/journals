require 'spec_helper'

describe Guardian do
  let(:profile){ build(:guardian) }
  let(:profile_type){ :guardian }
  let(:profile_class){ Guardian }

  it_behaves_like "a profile"

  describe "#email=" do
    it "is valid with a nil email" do
      profile.email = nil
      profile.should be_valid
    end

    it "is valid with a blank email" do
      profile.email = " "
      profile.should be_valid
    end
  end

  describe "#email" do
    it "returns nil if set to nil" do
      profile.email = nil
      profile.save!
      profile.email.should be_nil
    end
  end

  it "deactivates the user if saved with a blank email" do
    profile.reset_password
    profile.reload.should be_active
    profile.email = nil
    profile.save!
    profile.reload.should_not be_active
  end

  it "does not deactive the user if saved with a non-blank email" do
    profile.reset_password
    profile.email = "something@mail.com"
    profile.save!
    profile.reload.should be_active
  end

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

  describe "permissions:" do
    let(:student1){ create(:student) }
    let(:student2){ create(:student) }

    let(:profile){ create(:guardian, students: [student1, student2]) }

    let(:ability){ Ability.new(profile.user) }

    describe "posts:" do
      it "can create posts" do
        ability.should be_able_to :create, Post
      end

      it "can read, update and destroy its own posts" do
        own_post = build(:post, user: profile.user)
        own_post.initialize_tags
        own_post.save!
        ability.should be_able_to :read, own_post
        ability.should be_able_to :update, own_post
        ability.should be_able_to :destroy, own_post
      end

      context "when its students are not tagged in the post" do
        it "cannot read, edit or destroy posts created by a teacher" do
          post = create(:post, user: create(:teacher).user )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end

        it "cannot read, edit or destroy posts created by a student" do
          post = create(:post, user: create(:student).user )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end

        it "cannot read, edit or destroy posts created by another guardian" do
          post = build(:post, user: create(:guardian).user )
          post.initialize_tags
          post.save!
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
        own_comment = create(:comment, user: profile.user)
        ability.should be_able_to :manage, own_comment
      end

      it "can only read comments created by a teacher" do
        comment = create(:comment, user: create(:teacher).user )
        ability.should be_able_to :read, comment
        ability.should_not be_able_to :update, comment
        ability.should_not be_able_to :destroy, comment
      end

      it "can only read comments created by another student" do
        comment = create(:comment, user: create(:student).user )
        ability.should be_able_to :read, comment
        ability.should_not be_able_to :update, comment
        ability.should_not be_able_to :destroy, comment
      end

      it "can only read comments created by a guardian" do
        comment = create(:comment, user: create(:guardian).user )
        ability.should be_able_to :read, comment
        ability.should_not be_able_to :update, comment
        ability.should_not be_able_to :destroy, comment
      end
    end
  end
end