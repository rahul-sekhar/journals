class UnitsController < ApplicationController
  load_and_authorize_resource

  def index
    @units = @units.where(student_id: params[:student_id], subject_id: params[:subject_id])
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