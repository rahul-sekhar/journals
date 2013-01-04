require 'spec_helper'

describe ApplicationController do
  describe "current_user" do
    let(:teacher){ create(:teacher) }
    let(:user){ teacher.user }
    let(:user_id){ user.id }
    before{ user }

    it "is nil when not logged in" do
      controller.current_user.should be_nil
    end

    it "is nil when logged in with an invalid user" do
      session[:user_id] = user_id - 1
      controller.current_user.should be_nil
    end

    it "returns the user when logged in with a valid user" do
      session[:user_id] = user_id
      controller.current_user.should eq(user)
    end
  end
end