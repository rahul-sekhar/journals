require 'spec_helper'

describe SessionsController do
  describe "GET new" do
    it "has a 200 status code" do
      response.status.should eq(200)
    end

    it "assigns a new user object" do
      user = mock_model("User")
      User.should_receive(:new).and_return user
      get :new
      assigns(:user).should eq(user)
    end
  end

  describe "POST create" do
    context "with no data" do
      let(:make_request){ post :create }

      it "redirects to the login path" do
        make_request
        response.should redirect_to login_path
      end

      it "sets a flash message indicating invalid data" do
        make_request
        flash[:alert].should == "Invalid username or password"
      end

      it "clears the user in the session" do
        session[:user_id] = 1
        make_request
        session[:user_id].should be_nil
      end
    end

    context "with an invalid user" do
      before { User.stub(:authenticate).and_return(nil) }
      let(:make_request){ post :create, user:{ username: "user", password: "pass" } }

      it "authenticates the sent data" do
        User.should_receive(:authenticate).with("user", "pass")
        make_request
      end

      it "redirects to the login path" do
        make_request
        response.should redirect_to login_path
      end

      it "sets a flash message indicating invalid data" do
        make_request
        flash[:alert].should == "Invalid username or password"
      end

      it "clears the user in the session" do
        session[:user_id] = 1
        make_request
        session[:user_id].should be_nil
      end
    end

    context "with a valid user" do
      before do 
        user = mock_model(User)
        user.stub(:id).and_return(4)
        User.stub(:authenticate).and_return(user)
      end

      let(:make_request){ post :create, user:{ username: "user", password: "pass" } }

      it "authenticates the sent data" do
        User.should_receive(:authenticate).with("user", "pass")
        make_request
      end

      it "sets user in the session to the authenticated user" do
        make_request
        session[:user_id].should == 4
      end

      it "redirects to the root page if no intended url is found" do
        make_request
        response.should redirect_to root_path
      end

      it "redirects to the url that the user intended to visit if present" do
        session[:target_path] = "/some_path"
        make_request
        response.should redirect_to "/some_path"
      end
    end
  end
end