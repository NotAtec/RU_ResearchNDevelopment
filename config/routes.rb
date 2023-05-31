Rails.application.routes.draw do
  devise_for :users
  resources :games, only: [:index, :show, :new, :create, :update, :destroy]

  resources :tests, only: [:index]
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "games#index"	
end
