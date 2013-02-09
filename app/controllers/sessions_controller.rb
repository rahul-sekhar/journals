class SessionsController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]
  skip_before_filter :intercept_html
  skip_authorization_check

  def new
    @user = User.new
    @user.email = flash[:login_email] if flash[:login_email].present?
  end

  def create
    user = nil
    if params[:user].present?
      user = User.authenticate(params[:user][:email], params[:user][:password])
    end

    if user
      session[:user_id] = user.id
      redirect_back_or_to root_path
    else
      session.delete :user_id
      flash[:login_email] = params[:user][:email] if params[:user].present?
      redirect_to login_path, alert: "Invalid email or password"
    end
  end

  def destroy
    session.delete :user_id
    redirect_to login_path, notice: "You have been logged out"
  end
end