class StudentsController < ApplicationController
  load_and_authorize_resource

  def index
    @empty_message = "No students found."
    @filter = "students"
    @profiles = @students.current.alphabetical.search(params[:search]).page(params[:page])
    render "pages/people"
  end

  def show
  end

  def new
  end

  def create
    if @student.save
      redirect_to @student
    else
      redirect_to new_student_path, alert: "You must enter a name for the student."
    end
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
      redirect_to edit_student_path(@student), alert: @student.errors.full_messages.first
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
      if @student.groups.exists? @group
        redirect_to @student, alert: "#{@student.full_name} is already in the group \"#{@group.name}\""
      else
        @student.groups << @group
        redirect_to @student, notice: "#{@student.full_name} has been added to the group \"#{@group.name}\""
      end
    else
      redirect_to @student, alert: "Invalid group"
    end
  end

  def remove_group
    @group = Group.find_by_id(params[:group_id])
    
    if @group
      if @student.groups.exists? @group
        @student.groups.delete(@group)
        redirect_to @student, notice: "#{@student.full_name} has been removed from the group \"#{@group.name}\""
      else
        redirect_to @student, notice: "#{@student.full_name} was not in the group \"#{@group.name}\""
      end
    else
      redirect_to @student, alert: "Invalid group"
    end
  end

  def add_mentor
    @teacher = Teacher.find_by_id(params[:teacher_id])
    
    if @teacher
      if @student.mentors.exists? @teacher
        redirect_to @student, alert: "#{@teacher.full_name} is already a mentor for #{@student.full_name}"
      else
        @student.mentors << @teacher
        redirect_to @student, notice: "#{@teacher.full_name} has been added as a mentor for #{@student.full_name}"
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
        redirect_to @student, notice: "#{@teacher.full_name} is no longer a mentor for #{@student.full_name}"
      else
        redirect_to @student, notice: "#{@teacher.full_name} was not a mentor for #{@student.full_name}"
      end
    else
      redirect_to @student, alert: "Invalid teacher"
    end
  end
end