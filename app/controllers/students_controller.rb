class StudentsController < ApplicationController
  load_and_authorize_resource

  def index
    @empty_message = "No students found."
    @filter = "students"
    filter_and_display_people( @students.current )
  end

  def show
  end

  def create
    if @student.save
      redirect_to @student
    else
      flash[:student_data] = params[:student]
      redirect_to new_student_path, alert: @student.errors.full_messages.first
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
      if @student.mentors.exists? @teacher
        redirect_to @student, alert: "#{@teacher.full_name} is already #{@student.full_name}'s mentor"
      else
        @student.mentors << @teacher
        redirect_to @student, notice: "#{@teacher.full_name} is now #{@student.full_name}'s mentor"
      end
    else
      redirect_to @student, alert: "Invalid teacher"
    end
  end

  def remove_mentor
    @teacher = Teacher.find_by_id(params[:teacher_id])
    
    if @teacher
      if @student.mentors.exists? @teacher
        @student.mentors.delete(@teacher)
        redirect_to @student, notice: "#{@teacher.full_name} is no longer #{@student.full_name}'s mentor"
      else
        redirect_to @student, notice: "#{@teacher.full_name} was not #{@student.full_name}'s mentor"
      end
    else
      redirect_to @student, alert: "Invalid teacher"
    end
  end
end