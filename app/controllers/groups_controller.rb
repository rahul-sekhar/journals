class GroupsController < ApplicationController
  load_and_authorize_resource

  def index
    authorize! :manage, Group
    @groups = @groups.alphabetical
  end

  def show
    @empty_message = "No students in the group \"#{@group.name}\" found."
    @filter = @group
    filter_and_display_people( @group.students )
  end

  def create
    if @group.save
      render "show_short"
    else
      render text: @group.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
    if @group.update_attributes(params[:group])
      render "show_short"
    else
      render text: @group.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    render text: "OK", status: :ok
  end
end