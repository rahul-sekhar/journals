Journals::Application.routes.draw do
  root :to => "pages#home"

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  get "logout" => "sessions#destroy"

  get "people" => "pages#people"
  get "people/archived" => "pages#archived", as: "archived_people"
  get "mentees" => "pages#mentees"
  put "change_password" => "pages#update_password"

  get "user" => "pages#user"

  resources :posts, except: [:new, :edit] do
    resources :comments, only: [:create, :update, :destroy]
  end

  resources :students, except: [:new, :edit] do
    resources :guardians, only: [:create, :destroy] do
      collection do
        get :check_duplicates
      end
    end

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

  resources :teachers, except: [:new, :edit] do
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

  resources :guardians, only: [:show, :update] do
    member do
      post :reset
    end
  end

  resources :groups, except: [:new, :edit]

  match "*not_found", :to => "errors#not_found"
end
