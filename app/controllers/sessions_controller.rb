class SessionsController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    user = nil
    if params[:user].present?
      user = User.authenticate(params[:user][:username], params[:user][:password])
    end

    if user
      session[:user_id] = user.id
      redirect_back_or_to root_path
    else
      session.delete :user_id
      redirect_to login_path, alert: "Invalid username or password"
    end
  end
end