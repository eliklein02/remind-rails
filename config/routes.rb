Rails.application.routes.draw do
  # resources :organizations
  devise_for :organizations
  root "pages#home"
  get "/contacts/import" => "contacts#import_contacts"
  post "/contacts/import" => "contacts#import"

  get "sign_up" => "pages#sign_up"
  post "sign_up_form" => "pages#sign_up_form"

  resources :contacts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "about" => "pages#about"
  post "send_message" => "contacts#send_message", as: :send_message
  get "new_message" => "pages#new_message"
  get "privacy_policy" => "pages#privacy_policy"
  get "terms_of_service" => "pages#terms_of_service"
  get "contact" => "pages#contact"
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
