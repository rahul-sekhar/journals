class TeachersController < ApplicationController
  load_and_authorize_resource

  def show
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
      redirect_to edit_teacher_path(@teacher), alert: @teacher.errors.messages.first
    end
  end

  def destroy
    @teacher.destroy
    redirect_to people_path, notice: "The user \"#{@teacher.full_name}\" has been deleted"
  end

  def reset
    was_active = @teacher.active?
    password = @teacher.reset_password

    if was_active
      UserMailer.delay.reset_password_mail(@teacher, password)
    else
      UserMailer.delay.activation_mail(@teacher, password)
    end

    redirect_to @teacher, notice: "An email has been sent to the user with a randomly generated password"
  end
end