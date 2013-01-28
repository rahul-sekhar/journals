class CommentsController < ApplicationController
  load_and_authorize_resource :post
  load_and_authorize_resource :comment, through: :post
  skip_load_resource :comment, only: :create

  def create
    @comment = current_profile.comments.build(params[:comment])
    @comment.post = @post
    if @comment.save
      redirect_to @post
    else
      redirect_to @post, alert: "Please enter a comment"
    end
  end

  def edit
  end

  def update
    if @comment.update_attributes(params[:comment])
      redirect_to @post
    else
      redirect_to @post, alert: "Please enter a comment"
    end
  end

  def destroy
    @comment.destroy
    redirect_to @post, notice: "The comment has been deleted"
  end
end