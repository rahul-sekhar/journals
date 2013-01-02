require 'spec_helper'

describe PostsController do
  let(:user){ mock_model(User) }
  
  before do
    controller.stub(:current_user).and_return(user)
  end

  describe "GET index" do
    it "redirects to the login path if not logged in" do
      controller.stub(:current_user) 
      get :index
      response.should redirect_to login_path
    end

    it "has a status of 200 if logged in" do
      get :index
      response.status.should eq(200)
    end

    it "finds and assigns all posts" do
      post = mock_model(Post)
      Post.stub(:all).and_return([post])
      get :index
      assigns(:posts).should eq([post])
    end
  end
end