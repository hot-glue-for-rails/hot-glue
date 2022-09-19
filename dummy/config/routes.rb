Rails.application.routes.draw do
  devise_for :users

  root to: "welcome#index"
  resources :abcs
  resources :ghis
  resources :dfgs
  resources :cantelopes
end
