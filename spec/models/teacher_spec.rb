require 'spec_helper'

describe Teacher do
  let(:profile){ build(:teacher) }
  let(:profile_type){ :teacher }
  let(:profile_class){ Teacher }

  it_behaves_like "a profile"

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
    end

    context "with no user" do
      it "should be archivable" do
        profile.save!
        profile.toggle_archive
        profile.archived.should == true
        profile.toggle_archive
        profile.archived.should == false
      end
    end
  end

  describe "#remaining_students" do
    it "returns an empty array when no students exist" do
      profile.remaining_students.should be_empty
    end

    context "when some students exist" do
      before do
        @student1 = create(:student)
        @student2 = create(:student)
        @student3 = create(:student)
      end

      it "returns all students when the student has no mentees" do
        profile.remaining_students.should =~ [@student1, @student2, @student3]
      end

      it "returns an empty array when the student has all existing mentees" do
        profile.mentees = [@student1, @student2, @student3]
        profile.remaining_students.should be_empty
      end

      it "returns only students that are not added to the student already" do
        profile.mentees = [@student2]
        profile.remaining_students.should =~ [@student1, @student3]
      end
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

      it "can manage posts created by another teacher" do
        post = create(:post, author: create(:teacher) )
        ability.should be_able_to :manage, post
      end

      it "can manage posts created by a student" do
        post = create(:post, author: create(:student) )
        ability.should be_able_to :manage, post
      end

      it "can manage posts created by a guardian" do
        post = create(:post, author: create(:guardian) )
        ability.should be_able_to :manage, post
      end  
    end

    describe "comments:" do
      it "can create posts" do
        ability.should be_able_to :create, Comment
      end

      it "can manage its own comments" do
        own_comment = create(:comment, author: profile)
        ability.should be_able_to :manage, own_comment
      end

      it "can manage comments created by another teacher" do
        comment = create(:comment, author: create(:teacher) )
        ability.should be_able_to :manage, comment
      end

      it "can manage comments created by a student" do
        comment = create(:comment, author: create(:student) )
        ability.should be_able_to :manage, comment
      end

      it "can manage comments created by a guardian" do
        comment = create(:comment, author: create(:guardian) )
        ability.should be_able_to :manage, comment
      end
    end
  end
end