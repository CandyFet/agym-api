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
    User.find(params[:id]) == current_user ?
                              (render json: current_user, status: :ok) :
                              authorization_error
  rescue
    render json: User.find(params[:id]), adapter: :json_api,
    serializer: ErrorSerializer,
    status: :unprocessable_entity

  end

  def destroy; end
end
