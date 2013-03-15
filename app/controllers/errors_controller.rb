class ErrorsController < ApplicationController
  skip_authorization_check
  skip_before_filter :intercept_html

  def not_found
    respond_to do |format|
      format.json{ render text: "Page not found", status: :not_found }
      format.html{ render layout: "error" }
    end
  end
end