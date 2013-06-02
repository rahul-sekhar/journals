class UnitsController < ApplicationController
  load_and_authorize_resource
  load_resource :student, only: :index
  load_resource :subject, only: :index

  def index
    authorize! :view_academics, @student
    @units = @units.where(student_id: @student.id, subject_id: @subject.id)
  end

  def create
    if @unit.save
      render partial: 'unit', locals: { unit: @unit }
    else
      render text: @unit.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @unit.update_attributes(params[:unit])
      render partial: 'unit', locals: { unit: @unit }
    else
      render text: @unit.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @unit.destroy
    render text: "OK", status: :ok
  end
end