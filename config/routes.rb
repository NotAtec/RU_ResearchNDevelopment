Rails.application.routes.draw do
  devise_for :users
  resources :games, only: [:index, :show, :new, :create, :update, :destroy]

  resources :tests, only: [:index]
  # Custom route for the processing of selections in games. Should only be handled as a POST request 
  # with a turbo stream response.

  post "/games/:id", to: "games#process_choice", as: "process_choice"
  get "games/:id/result", to: "games#result", as: "result"
  get "welcome", to: "static_pages#welcome", as: "welcome"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "games#index"	
end
