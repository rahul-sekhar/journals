class TeachersController < ApplicationController
  load_and_authorize_resource

  def index
    @empty_message = "There are no teachers yet."
    @profiles = @teachers.current.alphabetical.page(params[:page])
    render "pages/people"
  end

  def show
  end

  def new
  end

  def create
    if @teacher.save
      redirect_to @teacher
    else
      redirect_to new_teacher_path, alert: "You must enter a name for the teacher."
    end
  end

  def edit
    # Pre-load data if present
    @teacher.assign_attributes(flash[:teacher_data]) if flash[:teacher_data]
  end

  def update
    if @teacher.update_attributes(params[:teacher])
      redirect_to @teacher
    else
      flash[:teacher_data] = params[:teacher]
      redirect_to edit_teacher_path(@teacher), alert: @teacher.errors.full_messages.first
    end
  end

  def destroy
    @teacher.destroy
    redirect_to people_path, notice: "The user \"#{@teacher.full_name}\" has been deleted"
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
        redirect_to @teacher, alert: "#{@teacher.full_name} is already a mentor for #{@student.full_name}"
      else
        @teacher.mentees << @student
        redirect_to @teacher, notice: "#{@teacher.full_name} has been added as a mentor for #{@student.full_name}"
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
        redirect_to @teacher, notice: "#{@teacher.full_name} is no longer a mentor for #{@student.full_name}"
      else
        redirect_to @teacher, notice: "#{@teacher.full_name} was not a mentor for #{@student.full_name}"
      end
    else
      redirect_to @teacher, alert: "Invalid student"
    end
  end
end