class PostsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:new, :create]

  def index
    @students = Student.current.alphabetical.filter_group(params[:group])
    params.delete(:student) unless contains_id?(@students, params[:student])
    @posts = @posts.filter_by_params(params).order{ created_at.desc }.page(params[:page]).per(6)
  end

  def show
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

  private

  def contains_id?(collection, id)
    ids = collection.map{ |object| object.id }
    return ids.include?(id.to_i)
  end
end