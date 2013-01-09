Journals::Application.routes.draw do
  root :to => "pages#home"

  get "login" => "sessions#new", as: "login"
  post "login" => "sessions#create"
  get "logout" => "sessions#destroy", as: "logout"

  get "people" => "pages#people", as: "people"

  resources :posts do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  resources :students, only: [:show, :edit, :update, :destroy] do
    resources :guardians, only: :destroy

    member do
      post :reset
      post :archive
      post :add_group, as: "add_group_to"
      post :remove_group, as: "remove_group_from"
      post :add_mentor, as: "add_mentor_to"
      post :remove_mentor, as: "remove_mentor_from"
    end
  end

  resources :teachers, only: [:show, :edit, :update, :destroy] do
    member do
      post :reset
      post :archive
      post :add_mentee, as: "add_mentee_to"
      post :remove_mentee, as: "remove_mentee_from"
    end
  end

  resources :guardians, only: [:show, :edit, :update] do
    member do
      post :reset
    end
  end
end
