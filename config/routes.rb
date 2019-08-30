Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:create, :show], param: :username

  resources :sessions, only: [:create, :destroy]
  
  post 'credentials/verify', to: 'credentials#verify'

  get 'seed', to: 'seeds#plant'

  namespace :admin do
    resources :sessions, only: [:create, :destroy]
    
    resources :users, only: [:show, :index, :destroy], param: :username do
      post 'logout', on: :member
    end

    resources :tokens, only: [:index]
  end
end
