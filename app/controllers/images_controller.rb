class ImagesController < ApplicationController
  load_and_authorize_resource

  def create
    @image = Image.new
    @image.file_name = params[:files][0]
    if !@image.save
      render :json => @image.errors.full_messages.first, :status => :unprocessable_entity
    end
  end
end