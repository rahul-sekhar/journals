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

  describe "GET edit" do
    let(:comment){ create(:comment, post: post_obj) }
    let(:make_request){ get :edit, post_id: post_obj.id, id: comment.id }

    it "has a status of 200" do
      make_request
      response.status.should eq(200)
    end

    it "assigns the comment to be edited" do
      make_request
      assigns(:comment).should eq(comment)
    end
  end

  describe "PUT update" do
    let(:comment){ create(:comment, post: post_obj) }

    context "with valid data" do
      let(:make_request) do 
        put :update, id: comment.id, post_id: post_obj.id, comment: { content: "Lorem Ipsum" }
      end

      it "finds the correct comment" do
        make_request
        assigns(:comment).should == comment
      end

      it "edits the comment" do
        make_request
        comment.reload.content.should == "Lorem Ipsum"
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
      let(:make_request) do 
        put :update, id: comment.id, post_id: post_obj.id, comment: { content: " " }
      end

      it "does not edit the comment" do
        comment.reload.content.should_not == "Lorem Ipsum"
      end
      
      it "redirects to the post page" do
        make_request
        response.should redirect_to post_path(post_obj)
      end

      it "displays a flash message indicating invalid data" do
        make_request
        flash[:alert].should == "Invalid comment"
      end
    end
  end

  describe "DELETE destroy" do
    let(:comment){ create(:comment, post: post_obj) }
    let(:make_request){ delete :destroy, id: comment.id, post_id: post_obj.id }

    it "finds the correct comment" do
      make_request
      assigns(:comment).should eq(comment)
    end

    it "destroys the comment" do
      make_request
      assigns(:comment).should be_destroyed
    end

    it "redirects to the post page" do
      make_request
      response.should redirect_to post_path(post_obj)
    end

    it "sets a flash message" do
      make_request
      flash[:notice].should == "The comment has been deleted"
    end
  end
end