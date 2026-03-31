Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "register", to: "registrations#new", as: :register
  post "register", to: "registrations#create"

  # OAuth routes
  namespace :auth do
    get "select_role", to: "role_selection#new", as: :select_role
    post "select_role", to: "role_selection#create"
  end

  # OmniAuth routes - middleware handles /auth/:provider POST automatically
  # Only callback routes need explicit definition
  get "/auth/:provider/callback", to: "auth/omniauth_callbacks#google_oauth2"
  post "/auth/:provider/callback", to: "auth/omniauth_callbacks#google_oauth2"
  get "/auth/failure", to: "auth/omniauth_callbacks#failure"

  # Driver routes
  namespace :driver do
    get "orders", to: "orders#index", as: :orders
  end

  # Customer routes
  namespace :customer do
    get "dashboard", to: "dashboard#index", as: :dashboard
  end

  # Driver profile management
  resource :driver_profile, only: [ :show, :edit, :update ] do
    post :update_location, on: :collection
  end

  # Defines the root path route ("/")
  root "pages#home"
end
