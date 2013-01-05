class CommentsController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    @comment = current_user.comments.build(params[:comment])
    @comment.post_id = post.id
    if @comment.save
      redirect_to post
    else
      redirect_to post, alert: "Invalid comment"
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    post = Post.find(params[:post_id])
    @comment = Comment.find(params[:id])

    if @comment.update_attributes(params[:comment])
      redirect_to post
    else
      redirect_to post, alert: "Invalid comment"
    end
  end
end