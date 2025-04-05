# frozen_string_literal: true

Rails.application.routes.draw do
  # Mount Ahoy engine
  mount Ahoy::Engine => '/ahoy'

  # Root route
  root 'application#home'

  draw(:pwa)
  # Devise routes for user authentication
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # User routes
  resources :users, only: %i[show edit update]

  # Snapshot routes
  resources :snapshots do
    collection do
      get 'weight_loss_predictor', to: 'snapshots#new'
      post 'weight_loss_predictor', to: 'snapshots#create'
    end
  end

  # One Rep Max routes
  resources :one_rep_maxes

  # Workout Routine and Exercise routes
  resources :workout_routines do
    resources :exercises
  end

  # Analytics routes
  get 'analytics', to: 'analytics#index'
  get 'ahoyanalytics', to: 'analytics#ahoyanalytics'

  # Activities routes
  get 'activities/index'
end
