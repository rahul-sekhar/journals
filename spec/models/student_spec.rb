require 'spec_helper'

describe Student do
  let(:profile){ build(:student) }
  let(:profile_type){ :student }
  let(:profile_class){ Student }

  it_behaves_like "a profile"

  it "is invalid without a user" do
    profile.user = nil
    profile.should be_invalid
  end

  describe "#email=" do
    it "is invalid with a nil email" do
      profile.email = nil
      profile.should be_invalid
    end

    it "is invalid with a blank email" do
      profile.email = " "
      profile.should be_invalid
    end
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
    it "destroys a guardian without other students" do
      create(:guardian, students: [profile])
      expect { profile.destroy }.to change { Guardian.count }.by(-1)
    end

    it "removes iteslf from a guardian with other students" do
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
      profile.save!
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
    context "if not archived" do
      let(:guardian1){ create(:guardian, students: [profile]) }
      let(:guardian2){ create(:guardian, students: [profile, create(:student)]) }
      let(:guardian3){ create(:guardian, students: [profile, create(:student, archived: true)]) }
      before{ profile.save! }

      it "should be archived" do
        profile.toggle_archive
        profile.reload.archived.should == true
      end

      it "should deactivate the user" do
        profile.user.should_receive(:deactivate)
        profile.toggle_archive
        profile.reload.should_not be_active
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
      let(:guardian1){ create(:guardian, students: [profile]) }
      let(:guardian2){ create(:guardian, students: [profile, create(:student)]) }
      let(:guardian3){ create(:guardian, students: [profile, create(:student, archived: true)]) }

      before do
        profile.archived = true
        profile.save!
      end

      it "should not be archived" do
        profile.toggle_archive
        profile.reload.archived.should == false
      end

      it "should not bother with guardians" do
        guardian2.reset_password
        profile.toggle_archive
        guardian1.reload.should_not be_active
        guardian2.reload.should be_active
        guardian3.reload.should_not be_active
      end
    end

    
  end

  describe "permissions:" do
    before{ profile.save! }
    let(:ability){ Ability.new(profile.user) }

    describe "posts:" do
      it "can create posts" do
        ability.should be_able_to :create, Post
      end

      it "can manage its own posts" do
        own_post = create(:post, user: profile.user)
        ability.should be_able_to :manage, own_post
      end

      context "when not tagged in the post" do
        it "cannot read, edit or destroy posts created by a teacher" do
          post = create(:post, user: create(:teacher).user )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end

        it "cannot read, edit or destroy posts created by another student" do
          post = create(:post, user: create(:student).user )
          ability.should_not be_able_to :read, post
          ability.should_not be_able_to :update, post
          ability.should_not be_able_to :destroy, post
        end

        it "cannot read, edit or destroy posts created by a guardian" do
          post = build(:post, user: create(:guardian).user )
          post.initialize_tags
          post.save!
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