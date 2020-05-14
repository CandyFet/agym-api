class RepostsController < ApplicationController
  def create
    repost = current_user.reposts.build(repost_params)
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

  def repost_params
    params.require(:repost).permit(:repostable_id, :repostable_type)
  end
end
