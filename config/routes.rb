Rails.application.routes.draw do
  get 'activities/index'
  get 'analytics/index'
  devise_for :users
  resources :users, only: [:show, :edit, :update] # Add this line to define user routes
  resources :snapshots
  resources :one_rep_maxes
  resources :workout_routines do
    resources :exercises
  end
  root to: "users#show"
  get 'weight_loss_predictor', to: 'snapshots#new'
  post 'weight_loss_predictor', to: 'snapshots#create'

  get 'analytics', to: 'analytics#index'
  get 'ahoyanalytics', to: 'analytics#ahoyanalytics'
end
