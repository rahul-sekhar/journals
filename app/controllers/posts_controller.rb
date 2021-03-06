class PostsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:new, :create]

  def index
    @posts = @posts.filter_by_params(params)
    @posts = @posts.order('posts.created_at DESC')
    @posts = @posts.load_associations
    @posts = paginate(@posts)
  end

  def show
  end

  def new
    raise ActiveRecord::RecordNotFound
  end

  def create
    # Fix for rails bug with an empty association attributes array
    params[:post][:student_observations_attributes] ||= [];

    @post = current_profile.posts.build(params[:post])

    if @post.save
      render 'show'
    else
      render text: @post.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def edit
    raise ActiveRecord::RecordNotFound
  end

  def update
    # Fix for rails bug with an empty association attributes array
    params[:post][:student_observations_attributes] ||= [];

    if @post.update_attributes(params[:post])
      render 'show'
    else
      render text: @post.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    render text: 'OK', status: :ok
  end

  private

  def contains_id?(collection, id)
    ids = collection.map{ |object| object.id }
    return ids.include?(id.to_i)
  end
end