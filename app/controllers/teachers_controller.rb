class TeachersController < ApplicationController
  load_and_authorize_resource

  def index
    filter_and_display_people( @teachers.current )
  end

  def show
  end

  def create
    if @teacher.save
      render 'show'
    else
      render text: @teacher.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @teacher.update_attributes(params[:teacher])
      render "show"
    else
      render text: @teacher.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @teacher.destroy
    rende text: 'OK', status: :ok
  end

  def reset
    if @teacher.email.nil?
      redirect_to @teacher, alert: "You must add an email address before you can activate the user"
      return
    end

    was_active = @teacher.active?
    password = @teacher.reset_password

    if was_active
      UserMailer.delay.reset_password_mail(@teacher, password)
    else
      UserMailer.delay.activation_mail(@teacher, password)
    end

    redirect_to @teacher, notice: "An email has been sent to the user with a randomly generated password"
  end

  def archive
    @teacher.toggle_archive

    if @teacher.archived
      message = "The user has been archived and can no longer login"
    else
      message = "The user is no longer archived and must be activated to allow a login"
    end

    redirect_to @teacher, notice: message
  end

  def add_mentee
    @student = Student.find_by_id(params[:student_id])
    
    if @student
      if @teacher.mentees.exists? @student
        redirect_to @teacher, alert: "#{@teacher.full_name} is already #{@student.full_name}'s mentor"
      else
        @teacher.mentees << @student
        redirect_to @teacher, notice: "#{@teacher.full_name} is now #{@student.full_name}'s mentor"
      end
    else
      redirect_to @teacher, alert: "Invalid student"
    end
  end

  def remove_mentee
    @student = Student.find_by_id(params[:student_id])
    
    if @student
      if @teacher.mentees.exists? @student
        @teacher.mentees.delete(@student)
        redirect_to @teacher, notice: "#{@teacher.full_name} is no longer #{@student.full_name}'s mentor"
      else
        redirect_to @teacher, notice: "#{@teacher.full_name} was not #{@student.full_name}'s mentor"
      end
    else
      redirect_to @teacher, alert: "Invalid student"
    end
  end
end