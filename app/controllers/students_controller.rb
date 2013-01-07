class StudentsController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def edit
    # Pre-load data if present
    @student.assign_attributes(flash[:student_data]) if flash[:student_data]
  end

  def update
    if @student.update_attributes(params[:student])
      redirect_to @student
    else
      flash[:student_data] = params[:student]
      redirect_to edit_student_path(@student), alert: @student.errors.messages.first
    end
  end

  def destroy
    @student.destroy
    redirect_to people_path, notice: "The user \"#{@student.full_name}\" has been deleted"
  end

  def reset
    if @student.email.nil?
      redirect_to @student, alert: "You must add an email address before you can activate the user"
      return
    end

    was_active = @student.active?
    password = @student.reset_password

    if was_active
      UserMailer.delay.reset_password_mail(@student, password)
    else
      UserMailer.delay.activation_mail(@student, password)
    end

    redirect_to @student, notice: "An email has been sent to the user with a randomly generated password"
  end

  def archive
    @student.toggle_archive

    if @student.archived
      message = "The user has been archived and can no longer login"
    else
      message = "The user is no longer archived and must be activated to allow a login"
    end

    redirect_to @student, notice: message
  end
end