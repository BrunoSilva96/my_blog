# frozen_string_literal: true

Rails.application.routes.draw do
  resources :posts, only: %i[index create update destroy show]

  resources :comments, only: %i[create]

  resources :users, only: %i[create]
  get '/me', to: 'users#me'
  post '/auth/login', to: 'auth#login'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
