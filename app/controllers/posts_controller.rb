class PostsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:new, :create]

  def index
    @posts = @posts.search(params[:search]).order{ created_at.desc }
    @posts = @posts.page(params[:page]).per(6)
  end

  def show
  end

  def new
    @post = current_profile.posts.build

    if flash[:post_data]
      # Pre-load post data if present
      @post.assign_attributes(flash[:post_data])
      
    else
      # Initialize the teacher or student tags if there is no post data to pre-load
      @post.initialize_tags
    end

    # Initialize student observations that may need to be set up because of
    # tagged students passed through flash data
    @post.initialize_observations
  end

  def create
    @post = current_profile.posts.build(params[:post])

    if @post.save
      redirect_to posts_path
    else
      flash[:post_data] = params[:post]
      redirect_to new_post_path, alert: @post.errors.full_messages.first
    end
  end

  def edit
    # Pre-load post data if present
    @post.assign_attributes(flash[:post_data]) if flash[:post_data]

    # Initialize student observations
    @post.initialize_observations
  end

  def update
    if @post.update_attributes(params[:post])
      redirect_to @post
    else
      flash[:post_data] = params[:post]
      redirect_to edit_post_path(@post), alert: @post.errors.full_messages.first
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "The post has been deleted"
  end
end