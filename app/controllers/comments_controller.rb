class CommentsController < ApplicationController
  load_and_authorize_resource :comment
  load_and_authorize_resource :post
  skip_load_resource :comment, only: :create

  def create
    @comment = current_profile.comments.build(params[:comment])
    @comment.post = @post
    if @comment.save
      render partial: 'comment', locals: { comment: @comment }
    else
      render text: 'Please enter a comment', status: :unprocessable_entity
    end
  end


  def update
    if @comment.update_attributes(params[:comment])
      render partial: 'comment', locals: { comment: @comment }
    else
      render text: 'Please enter a comment', status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    render text: 'OK', status: :ok
  end
end