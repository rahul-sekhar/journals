class MilestonesController < ApplicationController
  load_and_authorize_resource

  def update
    if @milestone.update_attributes(params[:milestone])
      render "show"
    else
      render text: @milestone.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @milestone.destroy
    render text: "OK", status: :ok
  end
end