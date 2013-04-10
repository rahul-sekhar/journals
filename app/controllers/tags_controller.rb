class TagsController < ApplicationController
  load_and_authorize_resource

  def index
    @tags = @tags.alphabetical
  end
end