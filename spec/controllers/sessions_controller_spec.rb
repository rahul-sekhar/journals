require 'spec_helper'

describe SessionsController do
  describe "GET new" do
    describe "when not logged in" do
      it "has a 200 status code" do
        get :new
        response.status.should eq(200)
      end

      it "assigns a new user object" do
        get :new
        assigns(:user).should be_a User
        assigns(:user).should be_new_record
      end

      it "leaves the users email blank" do
        get :new
        assigns(:user).email.should be_blank
      end

      context "if the flash login email has been set" do
        it "sets the users email" do
          get :new, nil, nil, login_email: "some@mail.com"
          assigns(:user).email.should == "some@mail.com"
        end
      end
    end

    describe "when logged in" do
      before do
        user = mock_model(User)
        controller.stub(:current_user).and_return(user)
        User.stub(:find).and_return(user)
        session[:user_id] = 5
      end

      it "redirects to the root page" do
        get :new
        response.should redirect_to root_path
      end
    end
  end

  describe "POST create" do
    context "with no data" do
      let(:make_request){ post :create }

      it "redirects to the login path" do
        make_request
        response.should redirect_to login_path
      end

      it "sets a flash alert" do
        make_request
        flash[:alert].should be_present
      end

      it "clears the user in the session" do
        session[:user_id] = 1
        make_request
        session[:user_id].should be_nil
      end
    end

    context "with an invalid user" do
      before { User.stub(:authenticate).and_return(nil) }
      let(:make_request){ post :create, user:{ email: "user@mail.com", password: "pass" } }

      it "authenticates the sent data" do
        User.should_receive(:authenticate).with("user@mail.com", "pass")
        make_request
      end

      it "redirects to the login path" do
        make_request
        response.should redirect_to login_path
      end

      it "sets a flash message indicating invalid data" do
        make_request
        flash[:alert].should == "Invalid email or password"
      end

      it "clears the user in the session" do
        session[:user_id] = 1
        make_request
        session[:user_id].should be_nil
      end

      it "sets the attempted email in the flash" do
        make_request
        flash[:login_email].should == "user@mail.com"
      end
    end

    context "with a valid user" do
      before do
        user = mock_model(User)
        user.stub(:id).and_return(4)
        User.stub(:authenticate).and_return(user)
      end

      let(:make_request){ post :create, user:{ email: "user@mail.com", password: "pass" } }

      it "authenticates the sent data" do
        User.should_receive(:authenticate).with("user@mail.com", "pass")
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

  describe "GET destroy" do
    before do
      user = mock_model(User)
      controller.stub(:current_user).and_return(user)
      User.stub(:find).and_return(user)
      session[:user_id] = 5
    end

    it "deletes the user id from the session" do
      get :destroy
      session[:user_id].should be_nil
    end

    it "redirects to the login path" do
      get :destroy
      response.should redirect_to login_path
    end

    it "sets a flash message" do
      get :destroy
      flash[:notice].should be_present
    end
  end
end