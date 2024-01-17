Rails.application.routes.draw do
  resources :searches
  resources :articles
  get "history", to:"searches#get_history"
  root "articles#index"
end
