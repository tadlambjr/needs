Rails.application.routes.draw do
  # Contact form
  resource :contact, only: [ :new, :create ], controller: "contact"

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
  resources :registrations, only: [ :new, :create ]

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

  resources :categories, except: [ :show ]

  resources :checklists do
    resources :checklist_items, only: [ :create, :update, :destroy ]
  end

  resources :need_signups, only: [ :create, :destroy ] do
    member do
      get :checklist
      patch :mark_complete
    end
  end

  resources :notifications, only: [ :index ] do
    member do
      patch :mark_as_read
    end

    collection do
      patch :mark_all_as_read
    end
  end

  # User profile and settings
  resource :profile, only: [ :show, :edit, :update ]
  resource :settings, only: [ :show, :update ]

  # Admin routes
  namespace :admin do
    root "dashboard#index"
    resources :users, only: [ :index, :edit, :update ] do
      collection do
        get :import
        post :process_import
      end
      member do
        post :transfer_ownership
      end
    end
    resources :reports, only: [ :index ]
    resources :rooms
  end

  # Room booking routes
  resources :room_bookings, only: [ :create, :destroy ] do
    member do
      patch :approve
      patch :reject
    end
  end

  # Donation routes
  resources :donations, only: [ :new, :create ] do
    collection do
      get :success
      get :manage
      patch :update_amount
      post :cancel
      post :reactivate
    end
  end

  # Webhooks
  post "/webhooks/stripe", to: "donations#webhook"
  post "/webhooks/postmark", to: "webhooks/postmark#create"
  post "/webhooks/telnyx", to: "webhooks/telnyx#create"

  # Admin constraint for Mission Control routes
  constraints(lambda { |request|
    session_id = request.cookie_jar.signed[:session_id]
    session = Session.find_by(id: session_id) if session_id
    user = session&.user

    user&.is_staff? == true
  }) do
    # Mount Mission Control - only accessible to admins
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  # Catch-all route for Mission Control to redirect non-admins
  get "/jobs(/*path)", to: "mission_control_access#redirect_non_admin"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
