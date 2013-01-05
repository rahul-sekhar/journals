require 'spec_helper'

describe CommentsController do
  let(:user){ create(:teacher).user }
  let(:post_obj){ create(:post) }
  before { controller.stub(:current_user).and_return(user) }

  describe "POST create" do
    context "with valid data" do
      let(:make_request){ post :create, { post_id: post_obj.id, comment: { content: "Lorem Ipsum" } } }

      it "creates a comment with the data passed" do
        expect{ make_request }.to change{ Comment.count }.by(1)
      end

      it "creates a comment that belongs to the correct post" do
        make_request
        assigns(:comment).post.should == post_obj
      end

      it "creates a comment that belongs to the correct user" do
        make_request
        assigns(:comment).user.should == user
      end

      it "creates a comment with the correct content" do
        make_request
        assigns(:comment).content.should == "Lorem Ipsum"
      end

      it "redirects to the post page" do
        make_request
        response.should redirect_to post_path(post_obj)
      end

      it "does not set a flash alert" do
        flash[:alert].should be_nil
      end
    end

    context "with invalid data" do
      let(:make_request){ post :create, post_id: post_obj.id }

      it "does not create a comment" do
        expect{ make_request }.to change{ Comment.count }.by(0)
      end
      
      it "redirects to the post page" do
        make_request
        response.should redirect_to post_path(post_obj)
      end

      it "displays a flash alert indicating invalid data" do
        make_request
        flash[:alert].should == "Invalid comment"
      end
    end
  end
end