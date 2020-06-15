Rails.application.routes.draw do
  post 'login', to: 'access_tokens#create'
  delete 'logout', to: 'access_tokens#destroy'
  post 'sign_up', to: 'registrations#create'

  concern :likeble do
    resources :likes, only: %i[index create destroy]
  end

  concern :repostable do
    resources :reposts, only: %i[create destroy]
  end

  concern :commentable do
    resources :comments, concerns: :likeble
  end

  resources :posts, concerns: %i[commentable likeble repostable]

  resources :articles, concerns: %i[commentable likeble repostable]

  resources :users
end
