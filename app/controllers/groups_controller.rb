class GroupsController < ApplicationController
  load_and_authorize_resource

  def index
    authorize! :manage, Group
    @groups = @groups.alphabetical
  end

  def show
    @empty_message = "No students in the group #{@group.name} found."
    @filter = @group
    @profiles = @group.students.alphabetical.page(params[:page])
    @profiles = @profiles.search(params[:search]) if params[:search].present?
    render "pages/people"
  end

  def new
  end

  def create
    if @group.save
      redirect_to groups_path, notice: "The group \"#{@group.name}\" has been created"
    else
      redirect_to new_group_path, alert: @group.errors.full_messages.first
    end
  end

  def edit
  end

  def update
    old_name = @group.name
    if @group.update_attributes(params[:group])
      redirect_to groups_path, notice: "\"#{old_name}\" has been renamed to \"#{@group.name}\""
    else
      redirect_to edit_group_path(@group), alert: @group.errors.full_messages.first
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: "\"#{@group.name}\" has been deleted"
  end
end