Journals::Application.routes.draw do
  root :to => "pages#home"

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  get "logout" => "sessions#destroy"

  get "people" => "pages#people"
  put "change_password" => "pages#update_password"

  get "user" => "pages#user"

  resources :posts do
    resources :comments, only: [:create, :update, :destroy]
  end

  resources :images, only: [:create]

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
  end

  resources :teachers, except: [:new, :edit] do
    member do
      post :reset
      post :archive
      post "mentees/:student_id", action: "add_mentee"
      delete "mentees/:student_id", action: "remove_mentee"
    end
  end

  resources :guardians, only: [:index, :show, :update] do
    member do
      post :reset
    end
  end

  resources :groups, except: [:new, :edit, :show]

  resources :tags, only: [:index]

  get "academics" => "pages#home"
  scope '/academics' do
    resources :subjects, except: [:new, :edit]
  end

  match "*not_found", :to => "errors#not_found"
end
