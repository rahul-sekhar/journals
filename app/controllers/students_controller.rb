class StudentsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: :all

  def index
    filter_and_display_people( @students.current )
  end

  def all
    authorize! :read, Student
    @students = Student.current
  end

  def show
  end

  def create
    if @student.save
      render 'show'
    else
      render text: @student.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @student.update_attributes(params[:student])
      render 'show'
    else
      render text: @student.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    render text: 'OK', status: :ok
  end

  def reset
    if @student.email.nil?
      render text: "You must add an email address before you can activate the user", status: :unprocessable_entity
      return
    end

    was_active = @student.active?
    password = @student.reset_password

    if was_active
      UserMailer.delay.reset_password_mail(@student, password)
    else
      UserMailer.delay.activation_mail(@student, password)
    end

    render text: 'OK', status: :ok
  end

  def archive
    @student.toggle_archive
    render text: 'OK', status: :ok
  end

  def add_group
    @group = Group.find_by_id(params[:group_id])

    if @group
      @student.groups << @group unless @student.groups.exists? @group
      render text: "OK", status: :ok
    else
      render text: "Group does not exist", status: :unprocessable_entity
    end
  end

  def remove_group
    @group = Group.find_by_id(params[:group_id])

    if @group
      @student.groups.delete(@group) if @student.groups.exists? @group
      render text: "OK", status: :ok
    else
      render text: "Group does not exist", status: :unprocessable_entity
    end
  end

  def add_mentor
    @teacher = Teacher.find_by_id(params[:teacher_id])

    if @teacher
      @student.mentors << @teacher unless @student.mentors.exists? @teacher
      render text: "OK", status: :ok
    else
      render text: "Teacher does not exist", status: :unprocessable_entity
    end
  end

  def remove_mentor
    @teacher = Teacher.find_by_id(params[:teacher_id])

    if @teacher
      @student.mentors.delete(@teacher) if @student.mentors.exists? @teacher
      render text: 'OK', status: :ok
    else
      render text: "Teacher does not exist", status: :unprocessable_entity
    end
  end
end