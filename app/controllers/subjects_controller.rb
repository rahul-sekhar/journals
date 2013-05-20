class SubjectsController < ApplicationController
  load_and_authorize_resource

  def index
    @subjects = @subjects.alphabetical
  end

  def show
  end

  def create
    if @subject.save
      render "show_short"
    else
      render text: @subject.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @subject.update_attributes(params[:subject])
      render "show_short"
    else
      render text: @subject.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @subject.destroy
    render text: "OK", status: :ok
  end
end