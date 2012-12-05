require 'spec_helper'

describe ApplicationController do
  describe "current_user" do
    let(:user){ create(:user, id: 5) }

    it "is nil when not logged in" do
      controller.current_user.should be_nil
    end

    it "is nil when logged in with an invalid user" do
      user
      session[:user_id] = 3
      controller.current_user.should be_nil
    end

    it "returns the user when logged in with a valid user" do
      user
      session[:user_id] = 5
      controller.current_user.should eq(user)
    end
  end
end