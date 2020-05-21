class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]

  def index
    articles = Article.recent
                      .page(params[:page])
                      .per(params[:per_page])
    
    render json: articles
  end

  def show
    article = Article.find(params[:id])

    render json: article
  end

  def create
    article = current_user.articles.build(article_params)
    article.save!
    render json: article, status: :created
  rescue
    render json: article, adapter: :json_api,
             serializer: ErrorSerializer,
             status: :unprocessable_entity
  end

  def update
    article = current_user.articles.find(params[:id])
    article.update!(article_params)
    render json: article, status: :ok
  rescue ActiveRecord::RecordNotFound
    authorization_error
  rescue
    render json: article, adapter: :json_api,
      serializer: ErrorSerializer,
      status: :unprocessable_entity
  end

  def destroy
    article = current_user.articles.find(params[:id])
    article.destroy
    head :no_content
  rescue
    authorization_error
  end

  private

  def article_params
    params.require(:data).require(:attributes).require(:header).
      permit(:title).
      merge(params.require(:data).require(:attributes).require(:body).
      permit(:text)) || 
    ActionController::Parameters.new
  end
end
