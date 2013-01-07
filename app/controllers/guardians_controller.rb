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
end