class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :current_profile, :logged_in?
  before_filter :require_login, :intercept_html
  check_authorization

  def intercept_html
    render inline: "", layout: "angular" if request.format.html?
  end

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
    @page = params[:page] || 1
    @people = collection.alphabetical
    @people = @people.search(params[:search]) if params[:search]
    
    @total_pages = get_total_pages(@people)
    @people = paginate(@people, @page)

    @people = @people.map{ |person| person.profile } if map_profiles

    render "pages/people"
  end

  def paginate(collection, page, per_page=per_page_default)
    collection = collection.limit(per_page)
    collection = collection.offset((page - 1) * per_page)
    return collection
  end

  def get_total_pages(collection, per_page=per_page_default)
    count = collection.count
    total = count / per_page
    total = total + 1 if (count % per_page > 0)
    return total
  end

  def per_page_default
    10
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
