Rails.application.routes.draw do
  devise_for :users

  root to: "welcome#index"
  resources :abcs
  resources :ghis
  resources :dfgs
  resources :jkls
  resources :cantelopes

  resources :pets

  resources :users
end
