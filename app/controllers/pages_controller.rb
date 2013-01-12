class PagesController < ApplicationController
  skip_authorization_check

  def home
    redirect_to posts_path
  end

  def people
    @empty_message = "No current students or teachers found."
    @filter = "all"
    @people = People.current.alphabetical.search(params[:search]).page(params[:page])
    @profiles = @people.map{ |person| person.profile }
  end

  def archived
    @empty_message = "No archived students or teachers found."
    @filter = "archived"
    @people = People.archived.alphabetical.page(params[:page])
    @profiles = @people.map{ |person| person.profile }
    render "people"
  end

  def mentees
    raise ActiveRecord::RecordNotFound unless current_profile.is_a? Teacher

    @empty_message = "No mentees found."
    @filter = "mentees"
    @profiles = current_profile.mentees.page(params[:page])
    render "people"
  end

  def change_password
  end

  def update_password

    if params['user']
      @current_pass = params['user']['current_password']
      @new_pass = params['user']['new_password']
    end

    if @current_pass.present? && @new_pass.present?
      current_user.current_password = @current_pass
      current_user.new_password = @new_pass
        
      if current_user.save
        redirect_to posts_path, notice: "Password changed successfully"
      else
        redirect_to change_password_path, alert: current_user.errors.full_messages.first
      end
    
    elsif @current_pass.blank?
      redirect_to change_password_path, alert: "Please enter your current password"

    elsif @new_pass.blank?
      redirect_to change_password_path, alert: "Please enter a new password"
    
    end
  end
end