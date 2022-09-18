Rails.application.routes.draw do
  devise_for :users

  root to: redirect("/abcs")

  resources :abcs
  resources :ghis

end
