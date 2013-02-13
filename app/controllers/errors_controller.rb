class ErrorsController < ApplicationController
  skip_authorization_check

  def not_found
    render text: "Page not found", status: :not_found
  end
end