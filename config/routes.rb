Rails.application.routes.draw do
  get "needs/index"
  get "needs/show"
  get "needs/new"
  get "needs/edit"
  get "needs/calendar"
  get "needs/my_needs"
  get "needs/pending_approval"
  get "home/index"
  resource :session
  resources :passwords, param: :token
  resources :registrations, only: [:new, :create]
  
  # Root route
  root "home#index"
  
  # Main application routes
  resources :needs do
    member do
      post :signup
      delete :cancel_signup
      patch :approve
      patch :reject
      patch :complete
    end
    
    collection do
      get :calendar
      get :my_needs
      get :pending_approval
    end
  end
  
  resources :categories, except: [:show]
  
  resources :checklists do
    resources :checklist_items, only: [:create, :update, :destroy]
  end
  
  resources :need_signups, only: [:create, :destroy] do
    member do
      get :checklist
      patch :mark_complete
    end
  end
  
  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
    
    collection do
      patch :mark_all_as_read
    end
  end
  
  # User profile and settings
  resource :profile, only: [:show, :edit, :update]
  resource :settings, only: [:show, :update]
  
  # Admin routes
  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :edit, :update]
    resources :reports, only: [:index]
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
