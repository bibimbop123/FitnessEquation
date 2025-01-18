Rails.application.routes.draw do
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
 
end
