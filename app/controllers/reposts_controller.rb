class RepostsController < ApplicationController
  include Behaveable::ResourceFinder
  include Behaveable::RouteExtractor

  before_action :set_repostable

  def create
    repost = current_user.reposts.build(repostable: @behaveable)
    repost.save!
    render json: repost, status: :created
  rescue
    render json: repost, adapter: :json_api,
    serializer: ErrorSerializer,
    status: :unprocessable_entity
  end

  def destroy
    repost = current_user.reposts.find(params[:id])
    repost.destroy
    head :no_content
  rescue
    authorization_error
  end

  private

  def set_repostable
    @behaveable ||= behaveable
    @behaveable ? @behaveable.reposts : Repost
  end
end
