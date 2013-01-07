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
end