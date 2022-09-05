Rails.application.routes.draw do

  root to: redirect("/abcs")

  resources :abcs
end
