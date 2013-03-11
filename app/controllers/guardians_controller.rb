class GuardiansController < ApplicationController
  load_and_authorize_resource

  def show
    @students = @guardian.students.alphabetical
  end

  def create
    @student = Student.find(params[:student_id])

    # Check for existing guardians with the same name for that student
    if @student.guardians.name_is(@guardian.first_name, @guardian.last_name)
      redirect_to @student, alert: "#{@student.full_name} already has a guardian named #{@guardian.full_name}"
      return
    end

    # Skip duplicate check if use_duplicate is set
    if (params[:use_duplicate].present?)
      if params[:use_duplicate].to_i > 0
        @guardian = Guardian.find(params[:use_duplicate])
      end
    else
      # Check for guardians with the same name for other students
      @duplicate_guardians = Guardian.names_are(@guardian.first_name, @guardian.last_name)
      if @duplicate_guardians.present?
        render "check_duplicates"
        return
      end
    end

    @guardian.students << @student

    if @guardian.save
      redirect_to @student
    else
      redirect_to new_student_guardian_path(@student), alert: @guardian.errors.full_messages.first
    end
  end

  def update
    if @guardian.update_attributes(params[:guardian])
      render "show"
    else
      render text: @guardian.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @student = Student.find(params[:student_id])
    @student.guardians.delete(@guardian)
    @guardian.check_students
    render text: 'OK', status: :ok
  end

  def reset
    if @guardian.email.nil?
      render text: "You must add an email address before you can activate the user", status: :unprocessable_entity
      return
    end

    was_active = @guardian.active?
    password = @guardian.reset_password

    if was_active
      UserMailer.delay.reset_password_mail(@guardian, password)
    else
      UserMailer.delay.activation_mail(@guardian, password)
    end

    render text: 'OK', status: :ok
  end
end