class PagesController < ApplicationController
  skip_authorization_check

  def home
    redirect_to posts_path
  end

  def people
    @empty_message = "There are no current students and teachers yet."
    @profiles = People.current.alphabetical.map{ |person| person.profile }
  end

  def archived
    @empty_message = "There are no archived students and teachers yet."
    @profiles = People.archived.alphabetical.map{ |person| person.profile }
    render "people"
  end
end