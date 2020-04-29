class PostsController < ApplicationController
  def index
    posts = Post.recent.
      page(params[:page]).
      per(params[:per_page])
    render json: posts
  end

  def show
    render json: Post.find(params[:id])
  end
end
