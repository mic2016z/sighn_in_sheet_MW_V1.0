Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "in/:slug", to: "visits#show", as: :sign_in_location
  post "in/:slug", to: "visits#create", as: :visits
  post "in/:slug/confirm", to: "visits#confirm_sign_in", as: :confirm_sign_in

  resources :locations, only: [ :index, :new, :create ] do
    member { get :poster }
  end

  resources :people, only: [ :index, :new, :create ]

  resources :visits, only: [ :edit, :update, :destroy ] do
    member { post :sign_out }
  end

  get "sign-someone-in", to: "manual_entries#new", as: :new_manual_entry
  post "sign-someone-in", to: "manual_entries#create", as: :manual_entries

  get "register", to: "register#show"
  get "register/export", to: "register#export", as: :export_register
  get "register/pdf", to: "register#pdf", as: :register_pdf

  get "hours", to: "hours#show"
  get "hours/export", to: "hours#export", as: :export_hours

  root to: redirect("/register")
end
