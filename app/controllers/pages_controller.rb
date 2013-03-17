class PagesController < ApplicationController
  skip_authorization_check

  def home
    redirect_to posts_path
  end

  def user
    @profile = current_profile
  end

  def people
    filter_and_display_people( People.current, true )
  end

  def archived
    filter_and_display_people( People.archived, true )
  end

  def mentees
    if current_profile.is_a? Teacher
      mentees = current_profile.mentees
    else
      mentees = Student.where("1 = 0")
    end
    filter_and_display_people( mentees )
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