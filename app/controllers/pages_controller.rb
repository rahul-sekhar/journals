class PagesController < ApplicationController
  skip_authorization_check

  def home
    redirect_to posts_path
  end

  def people
  end
end