class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(params[:post])
    if @post.save
      redirect_to posts_path
    else
      flash.now[:alert] = "Invalid post"
      render "new"
    end
  end
end