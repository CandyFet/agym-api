# frozen_string_literal: true

class CommentsController < ApplicationController
  include Behaveable::ResourceFinder
  include Behaveable::RouteExtractor

  skip_before_action :authorize!, only: %i[index show]

  def index
    comments = commentable.recent
                     .page(params[:page])
                     .per(params[:per_page])
    render json: comments
  end

  def show
    comment = commentable.find(params[:id])
    render json: comment
  end

  def create
    comment = commentable.build(
      comment_params.merge(user: current_user)
    )

    if comment.save
      render json: comment, status: :created, location: @post
    else
      render json: comment, adapter: :json_api,
             serializer: ErrorSerializer,
             status: :unprocessable_entity
    end
  end

  def update
    comment = current_user.comments.find(params[:id])
    comment.update!(comment_params)
    render json: comment, status: :ok
  rescue ActiveRecord::RecordNotFound
    authorization_error
  rescue StandardError
    render json: comment, adapter: :json_api,
           serializer: ErrorSerializer,
           status: :unprocessable_entity
  end

  def destroy
    comment = current_user.comments.find(params[:id])
    comment.destroy
  rescue ActiveRecord::RecordNotFound
    authorization_error
  end

  private

  def commentable
    @behaveable ||= behaveable
    @behaveable ? @behaveable.comments : Comment
  end

  def comment_params
    params.require(:comment).permit(:text)
  end
end
