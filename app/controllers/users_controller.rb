# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    users = User.all
                .page(params[:page])
                .per(params[:per_page])

    render json: users
  end

  def show
    render json: User.find(params[:id])
  end

  def update
    user = User.find(params[:id])
    user.update!(user_params)
    render json: user, status: :ok
  rescue ActionController::ParameterMissing
    authorization_error
  rescue StandardError => e
    render json: user, adapter: :json_api,
           serializer: ErrorSerializer,
           status: :unprocessable_entity
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    head :no_content
  rescue => e
    byebug
    authorization_error
  end

  private

  def user_params
    params.require(:data).require(:attributes).require(:header)
          .permit(:name,
                  :login,
                  :admin,
                  :ambassador,
                  :trainer,
                  :password) ||
      ActionController::Parameters.new
  end
end
