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

    # Initialize student observations that may need to be set up because of
    # tagged students passed through flash data
    @post.initialize_observations
  end

  def create
    @post = current_user.posts.build(params[:post])
    if @post.save
      redirect_to posts_path
    else
      flash[:post_data] = params[:post]
      redirect_to new_post_path, alert: "Invalid post"
    end
  end

  def edit
    @post = Post.find(params[:id])

    # Pre-load post data if present
    @post.assign_attributes(flash[:post_data]) if flash[:post_data]

    # Initialize student observations
    @post.initialize_observations
  end

  def update
    @post = Post.find(params[:id])

    if @post.update_attributes(params[:post])
      redirect_to @post
    else
      flash[:post_data] = params[:post]
      redirect_to edit_post_path(@post), alert: "Invalid post"
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "The post has been deleted"
  end
end