require 'spec_helper'

describe CommentsController do
  let(:user){ create(:teacher_with_user).user }
  let(:post_obj){ create(:post) }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Post
    ability.can :manage, Comment
  end

  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, post_id: post_obj.id, comment: { content: "Lorem Ipsum" }, format: :json }

      it "raises an exception if the user cannot read the post" do
        ability.cannot :read, post_obj
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "raises an exception if the user cannot create a comment" do
        ability.cannot :create, Comment
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "creates a comment with the data passed" do
        expect{ make_request }.to change{ Comment.count }.by(1)
      end

      it "creates a comment that belongs to the correct post" do
        make_request
        assigns(:comment).post.should == post_obj
      end

      it "creates a comment that belongs to the correct user" do
        make_request
        assigns(:comment).author.should == user.profile
      end

      it "creates a comment with the correct content" do
        make_request
        assigns(:comment).content.should == "Lorem Ipsum"
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, post_id: post_obj.id, format: :json }

      it "does not create a comment" do
        expect{ make_request }.to change{ Comment.count }.by(0)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end

  describe "PUT update" do
    let(:comment){ create(:comment, post: post_obj) }

    context "with valid data" do
      let(:make_request) do
        put :update, id: comment.id, post_id: post_obj.id, comment: { content: "Lorem Ipsum" }, format: :json
      end

      it "raises an exception if the user cannot read the post" do
        ability.cannot :read, post_obj
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "raises an exception if the user cannot edit that comment" do
        ability.cannot :update, comment
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "finds the correct comment" do
        make_request
        assigns(:comment).should == comment
      end

      it "edits the comment" do
        make_request
        comment.reload.content.should == "Lorem Ipsum"
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      let(:make_request) do
        put :update, id: comment.id, post_id: post_obj.id, comment: { content: " " }, format: :json
      end

      it "does not edit the comment" do
        comment.reload.content.should_not == "Lorem Ipsum"
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end

  describe "DELETE destroy" do
    let(:comment){ create(:comment, post: post_obj) }
    let(:make_request){ delete :destroy, id: comment.id, post_id: post_obj.id, format: :json }

    it "raises an exception if the user cannot read the post" do
      ability.cannot :read, post_obj
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "raises an exception if the user cannot edit that comment" do
      ability.cannot :destroy, comment
      expect{ make_request }.to raise_exception(CanCan::AccessDenied)
    end

    it "finds the correct comment" do
      make_request
      assigns(:comment).should eq(comment)
    end

    it "destroys the comment" do
      make_request
      assigns(:comment).should be_destroyed
    end

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end
  end
end