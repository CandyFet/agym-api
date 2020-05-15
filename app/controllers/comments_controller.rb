# frozen_string_literal: true

class CommentsController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]
  before_action :load_post

  def index
    @comments = @post.comments.recent
                     .page(params[:page])
                     .per(params[:per_page])

    render json: @comments
  end

  def show
    @comment = @post.comments.find(params[:id])
    render json: @comment
  end

  def create
    @comment = @post.comments.build(
      comment_params.merge(user: current_user)
    )

    if @comment.save
      render json: @comment, status: :created, location: @post
    else
      render json: @comment, adapter: :json_api,
             serializer: ErrorSerializer,
             status: :unprocessable_entity
    end
  end

  def update
    @comment = current_user.comments.find(params[:id])
    @comment.update!(comment_params)
    render json: @comment, status: :ok
  rescue ActiveRecord::RecordNotFound
    authorization_error
  rescue StandardError
    render json: @comment, adapter: :json_api,
           serializer: ErrorSerializer,
           status: :unprocessable_entity
  end

  def destroy
    @comment = current_user.comments.find(params[:id])
    @comment.destroy
  rescue ActiveRecord::RecordNotFound
    authorization_error
  end

  private

  def load_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:text)
  end
end
