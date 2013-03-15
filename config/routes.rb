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

  get "user" => "pages#user"

  resources :posts do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  resources :students do
    resources :guardians, only: [:new, :create, :destroy]

    member do
      post :reset
      post :archive
      post "groups/:group_id", action: "add_group"
      delete "groups/:group_id", action: "remove_group"
      post "mentors/:teacher_id", action: "add_mentor"
      delete "mentors/:teacher_id", action: "remove_mentor"
    end

    collection do
      get :all
    end
  end

  resources :teachers do
    member do
      post :reset
      post :archive
      post "mentees/:student_id", action: "add_mentee"
      delete "mentees/:student_id", action: "remove_mentee"
    end

    collection do
      get :all
    end
  end

  resources :guardians, only: [:show, :edit, :update] do
    member do
      post :reset
    end
  end

  resources :groups

  match "*not_found", :to => "errors#not_found"
end
