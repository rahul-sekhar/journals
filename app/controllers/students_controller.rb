class StudentsController < ApplicationController
  load_and_authorize_resource

  def show
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
      redirect_to edit_student_path(@student), alert: @student.errors.messages.first
    end
  end
end