Rails.application.routes.draw do
  devise_for :users
  resources :games, only: [:index, :show, :new, :create, :update, :destroy]

  resources :tests, only: [:index]

  # Friend request resources, but with custom routes.
  get "friends", to: "friend_requests#index", as: "friends"
  post "friends", to: "friend_requests#create"
  patch "friends/:id", to: "friend_requests#update", as: "friend"
  delete "friends/:id", to: "friend_requests#destroy"

  # Singular routes that aren't resourceful.
  post "/games/:id", to: "games#process_choice", as: "process_choice"
  get "games/:id/result", to: "games#result", as: "result"
  get "welcome", to: "static_pages#welcome", as: "welcome"


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "games#index"	
end
