require 'spec_helper'

describe ApplicationController do
  describe "current_user" do
    let(:user){ create(:teacher_with_user).user }
    before{ user }

    it "is nil when not logged in" do
      controller.current_user.should be_nil
    end

    it "is nil when logged in with an invalid user" do
      session[:user_id] = user.id - 1
      controller.current_user.should be_nil
    end

    it "returns the user when logged in with a valid user" do
      session[:user_id] = user.id
      controller.current_user.should eq(user)
    end
  end
end