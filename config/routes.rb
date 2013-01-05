Journals::Application.routes.draw do
  root :to => "pages#home"

  get "login" => "sessions#new", as: "login"
  post "login" => "sessions#create"
  get "logout" => "sessions#destroy", as: "logout"

  resources :posts do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end
end
