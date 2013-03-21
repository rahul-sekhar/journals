class PostsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:new, :create]

  def index
    @posts = @posts.load_associations
    @posts = @posts.filter_by_params(params).order{ created_at.desc }
    @posts = paginate(@posts)
  end

  def show
  end

  def create
    @post = current_profile.posts.build(params[:post])

    if @post.save
      render 'show'
    else
      render text: @post.errors.full_messages.first, status: :unprocessable_entity
    end
  end

  def update
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