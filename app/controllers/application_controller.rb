class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :current_profile, :logged_in?
  before_filter :require_login
  check_authorization

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def current_profile
    current_user.profile
  end

  def logged_in?
    current_user
  end

  def filter_and_display_people(collection, map_profiles = false)
    @profiles = collection.alphabetical
    @profiles = @profiles.search(params[:search]) if params[:search]
    @profiles = @profiles.page(params[:page])

    @profiles = @profiles.map{ |person| person.profile } if map_profiles

    render "pages/people"
  end

  protected
  def store_target_path
    session[:target_path] = request.fullpath
  end

  def clear_target_path
    session.delete :target_path
  end

  def redirect_back_or_to(default_path)
    redirect_to session[:target_path] || default_path
    clear_target_path
  end

  private
  def require_login
    unless logged_in?
      store_target_path
      redirect_to login_path
    end
  end
end
