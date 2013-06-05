class StrandsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: [:add_milestone, :add_strand]

  def add_milestone
    authorize! :create, Milestone

    @milestone = @strand.add_milestone(params[:milestone][:level], params[:milestone][:content])
    if @milestone.new_record?
      render text: @milestone.errors.full_messages.first, status: :unprocessable_entity
    else
      render "milestones/show"
    end
  end

  def add_strand
    authorize! :create, Strand

    @strand = @strand.add_strand(params[:strand][:name])
    if @strand.new_record?
      render text: @strand.errors.full_messages.first, status: :unprocessable_entity
    else
      render "show"
    end
  end

  def update
    if @strand.update_attributes(params[:strand])
      render "show"
    else
      render text: @strand.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @strand.destroy
    render text: "OK", status: :ok
  end
end