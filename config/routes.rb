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

  resources :posts, concerns: %i[likeble repostable] do
    resources :comments, concerns: :likeble
  end
end
