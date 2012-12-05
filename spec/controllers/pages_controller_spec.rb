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

    it "has a 200 status code if logged in" do
      get :home
      response.status.should eq(200)
    end
  end
end