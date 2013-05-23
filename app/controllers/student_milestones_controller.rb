class StudentMilestonesController < ApplicationController
  load_and_authorize_resource
  load_and_authorize_resource :student, only: [:create]

  def create
    @student_milestone.student = @student
    if @student_milestone.save
      render partial: 'student_milestone', locals: { student_milestone: @student_milestone }
    else
      render text: @student_milestone.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @student_milestone.update_attributes(params[:student_milestone])
      render partial: 'student_milestone', locals: { student_milestone: @student_milestone }
    else
      render text: @student_milestone.errors.full_messages.first, status: :unprocessable_entity
    end
  end
end