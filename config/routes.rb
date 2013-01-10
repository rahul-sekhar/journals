Journals::Application.routes.draw do
  root :to => "pages#home"

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  get "logout" => "sessions#destroy"

  get "people" => "pages#people"
  get "people/archived" => "pages#archived", as: "archived_people"
  get "mentees" => "pages#mentees"
  get "change_password" => "pages#change_password"
  put "change_password" => "pages#update_password"

  resources :posts do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  resources :students do
    resources :guardians, only: [:new, :create, :destroy]

    member do
      post :reset
      post :archive
      post :add_group, as: "add_group_to"
      post :remove_group, as: "remove_group_from"
      post :add_mentor, as: "add_mentor_to"
      post :remove_mentor, as: "remove_mentor_from"
    end
  end

  resources :teachers do
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

  resources :groups
end
