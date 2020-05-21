class LikesController < ApplicationController
  include Behaveable::ResourceFinder
  include Behaveable::RouteExtractor
  skip_before_action :authorize!, only: :index
  before_action :set_likeble

  def index
    @likes = set_likeble
    render json: @likes
  end

  def create
    like = current_user.likes.build(likeble: @behaveable)
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

  def set_likeble
    @behaveable ||= behaveable
    @behaveable ? @behaveable.likes : Like
  end
end
