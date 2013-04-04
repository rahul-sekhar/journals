class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :current_profile, :logged_in?
  before_filter :require_login, :intercept_html
  check_authorization

  # Error handling
  if Rails.application.config.handle_exceptions
    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
    rescue_from ActionController::RoutingError,
                ActionController::UnknownController,
                ::AbstractController::ActionNotFound,
                ActiveRecord::RecordNotFound,
                CanCan::AccessDenied,
                with: lambda { |exception| render_error 404, exception }
  end

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

  def paginate(collection, per_page=per_page_default)
    @page = params[:page].to_i
    @page = 1 if @page < 1

    @total_pages = get_total_pages(collection, per_page)

    collection = collection.limit(per_page)
    collection = collection.offset((@page - 1) * per_page)
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

  def render_error(status, exception)
    logger.fatal "ERROR #{status}:\n#{exception.to_yaml}"

    if status == 404
      respond_to do |format|
        format.html { render template: "errors/not_found", layout: 'layouts/error', status: status }
        format.json{ render text: "Page not found", status: :not_found }
      end
    else
      respond_to do |format|
        format.html { render template: "errors/internal error", layout: 'layouts/error', status: status }
        format.json{ render text: "Internal error", status: :internal_server_error }
      end
    end

  end
end
