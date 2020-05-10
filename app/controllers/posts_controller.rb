# frozen_string_literal: true

class PostsController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]

  def index
    posts = Post.recent
                .page(params[:page])
                .per(params[:per_page])
    render json: posts
  end

  def show
    render json: Post.find(params[:id])
  end

  def create
    post = current_user.posts.build(post_params)
    post.save!
    render json: post, status: :created
  rescue
    render json: post, adapter: :json_api,
             serializer: ErrorSerializer,
             status: :unprocessable_entity
  end

  def update
    post = current_user.posts.find(params[:id])
    post.update!(post_params)
    render json: post, status: :ok
  rescue ActiveRecord::RecordNotFound
    authorization_error
  rescue
    render json: post, adapter: :json_api,
      serializer: ErrorSerializer,
      status: :unprocessable_entity
  end

  def destroy
    post = current_user.posts.find(params[:id])
    post.destroy
    head :no_content
  rescue
    authorization_error
  end

  private

  def post_params
    params.require(:data).require(:attributes).
      permit(:title, :text) || 
    ActionController::Parameters.new
  end
end
