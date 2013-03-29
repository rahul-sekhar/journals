class TeachersController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: :all

  def index
    filter_and_display_people( @teachers.current )
  end

  def all
    authorize! :read, Teacher
    @teachers = Teacher.all
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
    render text: 'OK', status: :ok
  end

  def reset
    if @teacher.email.nil?
      render text: "You must add an email address before you can activate the user", status: :unprocessable_entity
      return
    end

    was_active = @teacher.active?
    password = @teacher.reset_password

    if was_active
      UserMailer.delay.reset_password_mail(@teacher, password)
    else
      UserMailer.delay.activation_mail(@teacher, password)
    end

    render text: 'OK', status: :ok
  end

  def archive
    @teacher.toggle_archive
    render text: 'OK', status: :ok
  end

  def add_mentee
    @student = Student.find_by_id(params[:student_id])

    if @student
      @teacher.mentees << @student unless @teacher.mentees.exists? @student
      render text: 'OK', status: :ok
    else
      render text: 'Student does not exist', status: :unprocessable_entity
    end
  end

  def remove_mentee
    @student = Student.find_by_id(params[:student_id])

    if @student
      @teacher.mentees.delete(@student) if @teacher.mentees.exists? @student
      render text: 'OK', status: :ok
    else
      render text: 'Student does not exist', status: :unprocessable_entity
    end
  end
end