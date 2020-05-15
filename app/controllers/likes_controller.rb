class LikesController < ApplicationController
skip_before_action :authorize!, only: :index

  def index
    @likes = set_likeble.likes
    render json: @likes
  end

  def create
    like = current_user.likes.build(like_params)
    like.save!
    render json: like, status: :created
  rescue
    render json: like, adapter: :json_api,
             serializer: ErrorSerializer,
             status: :unprocessable_entity
  end

  def destroy
    like = current_user.likes.find(params[:id])
    like.destroy
    head :no_content
  rescue
    authorization_error
  end

  private

  def like_params
    params.require(:like).permit(:likeble_id, :likeble_type)
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:comment_id]) if params[:comment_id].present?
  end

  def set_likeble
    set_comment.present? ? set_comment : set_post
  end
end
