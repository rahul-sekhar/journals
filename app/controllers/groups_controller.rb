class GroupsController < ApplicationController
  load_and_authorize_resource

  def index
    authorize! :manage, Group
    @groups = @groups.alphabetical
  end

  def show
    @empty_message = "There are no students in this group yet."
    @profiles = @group.students
    render "pages/people"
  end

  def new
  end

  def create
    if @group.save
      redirect_to people_path, notice: "The group \"#{@group.name}\" has been created"
    else
      redirect_to new_group_path, alert: "Invalid group name"
    end
  end

  def edit
  end

  def update
    old_name = @group.name
    if @group.update_attributes(params[:group])
      redirect_to groups_path, notice: "\"#{old_name}\" has been renamed to \"#{@group.name}\""
    else
      redirect_to edit_group_path(@group), alert: "Invalid group name"
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: "\"#{@group.name}\" has been deleted"
  end
end