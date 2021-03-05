Rails.application.routes.draw do
  root to: "application#show"

  resources :abc
end