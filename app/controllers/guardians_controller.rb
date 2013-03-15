class GuardiansController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: :check_duplicates

  def show
    @students = @guardian.students.alphabetical
  end

  def create
    @student = Student.find(params[:student_id])

    if params[:guardian_id]
      @guardian = Guardian.find_by_id(params[:guardian_id])

      if !@guardian
        render text: 'Guardian does not exist', status: :unprocessable_entity
        return
      end
    end

    @guardian.students << @student

    if @guardian.save
      render "show"
    else
      render text: @guardian.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def check_duplicates
    authorize! :create, Guardian

    @student = Student.find(params[:student_id])
    name = params[:name]

    if name.blank?
      render text: 'Name required to check duplicates', status: :unprocessable_entity
      return
    end

    guardian = Guardian.new(full_name: name)

    # Check for existing guardians with the same name for that student
    if @student.guardians.name_is(guardian.first_name, guardian.last_name)
      render text: "#{@student.full_name} already has a guardian named #{name}", status: :unprocessable_entity
      return
    end
    @duplicate_guardians = Guardian.names_are(guardian.first_name, guardian.last_name)
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