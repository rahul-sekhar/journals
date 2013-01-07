class GuardiansController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def edit
    # Pre-load data if present
    @guardian.assign_attributes(flash[:guardian_data]) if flash[:guardian_data]
  end

  def update
    if @guardian.update_attributes(params[:guardian])
      redirect_to @guardian
    else
      flash[:guardian_data] = params[:guardian]
      redirect_to edit_guardian_path(@guardian), alert: @guardian.errors.messages.first
    end
  end

  def destroy
    @student = Student.find(params[:student_id])
    @student.guardians.delete(@guardian)
    @guardian.check_students

    if @guardian.destroyed?
      redirect_to @student, notice: "The user \"#{@guardian.full_name}\" has been deleted"
    else
      redirect_to @student, notice: "The user \"#{@guardian.full_name}\" has been removed for the student \"#{@student.full_name}\""
    end
  end

  def reset
    if @guardian.email.nil?
      redirect_to @guardian, alert: "You must add an email address before you can activate the user"
      return
    end

    was_active = @guardian.active?
    password = @guardian.reset_password

    if was_active
      UserMailer.delay.reset_password_mail(@guardian, password)
    else
      UserMailer.delay.activation_mail(@guardian, password)
    end

    redirect_to @guardian, notice: "An email has been sent to the user with a randomly generated password"
  end
end