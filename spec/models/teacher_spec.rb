require 'spec_helper'

describe Teacher do
  let(:profile){ build(:teacher) }
  let(:profile_type){ :teacher }
  let(:profile_class){ Teacher }

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

  describe "#name_with_type" do
    it "returns the full name along with the profile type" do
      profile.first_name = "Rahul"
      profile.last_name = "Sekhar"
      profile.name_with_type.should == "Rahul Sekhar (teacher)"
    end
  end

  describe "#toggle_archive" do
    context "if archived" do
      before do 
        profile.archived = true
        profile.save!
      end

      it "should not be archived" do
        profile.toggle_archive
        profile.reload.archived.should == false
      end
    end

    context "if not archived" do
      before{ profile.save! }

      it "should be archived" do
        profile.toggle_archive
        profile.reload.archived.should == true
      end

      it "should deactivate the user" do
        profile.user.should_receive(:deactivate)
        profile.toggle_archive
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

      it "can manage posts created by another teacher" do
        post = create(:post, user: create(:teacher).user )
        ability.should be_able_to :manage, post
      end

      it "can manage posts created by a student" do
        post = create(:post, user: create(:student).user )
        ability.should be_able_to :manage, post
      end

      it "can manage posts created by a guardian" do
        post = build(:post, user: create(:guardian).user )
        post.initialize_tags
        post.save!
        ability.should be_able_to :manage, post
      end  
    end

    describe "comments:" do
      it "can create posts" do
        ability.should be_able_to :create, Comment
      end

      it "can manage its own comments" do
        own_comment = create(:comment, user: profile.user)
        ability.should be_able_to :manage, own_comment
      end

      it "can manage comments created by another teacher" do
        comment = create(:comment, user: create(:teacher).user )
        ability.should be_able_to :manage, comment
      end

      it "can manage comments created by a student" do
        comment = create(:comment, user: create(:student).user )
        ability.should be_able_to :manage, comment
      end

      it "can manage comments created by a guardian" do
        comment = create(:comment, user: create(:guardian).user )
        ability.should be_able_to :manage, comment
      end
    end
  end
end