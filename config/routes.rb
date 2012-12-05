Journals::Application.routes.draw do
  root :to => "pages#home"

  get "login" => "sessions#new", as: "login"
  post "login" => "sessions#create"
end
