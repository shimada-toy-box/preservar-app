Rails.application.routes.draw do

  devise_for :users
  root to: 'home#index'

  get '/tos', to: 'home#tos', as: :tos_path
  get '/privacy', to: 'home#privacy', as: :privacy_path

  devise_for :admin_users, path: 'admin'

  namespace :admin do
    resources :users
    resources :admin_users
    resources :categories
    resources :sellers

    root to: "users#index"
  end

  authenticate :admin_user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
