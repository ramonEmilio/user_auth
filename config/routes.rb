Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:create], param: :username do
    member do
      post 'authenticate'
    end
  end

  resources :tokens, only: [:create, :delete]
  post 'token/authenticate', to: 'tokens#authenticate'
end
