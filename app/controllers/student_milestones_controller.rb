class StudentMilestonesController < ApplicationController
  load_and_authorize_resource
  load_resource :student, only: [:index, :create]

  def index
    authorize! :view_academics, @student
    @subject = Subject.find(params[:subject_id])
    @student_milestones = @student.student_milestones.from_subject(@subject).order{updated_at.desc}.limit(5).load_associations
  end

  def create
    authorize! :read, @student
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