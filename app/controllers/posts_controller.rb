class PostsController < ApplicationController
  def index
    @posts = Post.limit(10)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = current_user.posts.build

    if flash[:post_data]
      # Pre-load post data if present
      @post.assign_attributes(flash[:post_data])
      
    else
      # Initialize the teacher or student tag if there is no post data to pre-load
      @post.initialize_tag
    end
  end

  def create
    @post = current_user.posts.build(params[:post])
    if @post.save
      redirect_to posts_path
    else
      flash[:alert] = "Invalid post"
      flash[:post_data] = params[:post]
      redirect_to new_post_path
    end
  end
end