class ErrorsController < ApplicationController
  skip_authorization_check
  skip_before_filter :intercept_html

  def not_found
    respond_to do |format|
      format.json{ render text: "Page not found", status: :not_found }
      format.html{ render layout: "error" }
    end
  end

  def internal_error
    respond_to do |format|
      format.json{ render text: "Internal error", status: :internal_server_error }
      format.html{ render layout: "error" }
    end
  end
end