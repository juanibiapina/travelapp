Rails.application.routes.draw do
  devise_for :accounts, controllers: {
    omniauth_callbacks: "accounts/omniauth_callbacks",
    registrations: "accounts/registrations"
  }

  resources :trips do
    resources :links
    resources :places
    resources :trip_events
    resources :invites, only: [ :create, :destroy, :index ]
    get :members, on: :member
    get :timeline, on: :member
  end

  # Public invite acceptance route
  get "invite/:token", to: "invites#accept", as: :accept_invite

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "trips#index"
end
