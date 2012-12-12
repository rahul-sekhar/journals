require 'spec_helper'

describe PagesController do
  let(:user){ mock_model(User) }
  
  before do
    controller.stub(:current_user).and_return(user)
  end

  describe "GET home" do
    it "redirects to the login path if not logged in" do
      controller.stub(:current_user) 
      get :home
      response.should redirect_to login_path
    end

    it "redirects to the posts page if logged in" do
      get :home
      response.should redirect_to posts_path
    end
  end
end