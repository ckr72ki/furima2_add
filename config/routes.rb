Rails.application.routes.draw do
  get 'messages/new'
  get 'cards/new'
  get 'users/show'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  devise_scope :user do
    get 'addresses', to: 'users/registrations#new_address'
    post 'addresses', to: 'users/registrations#create_address'
  end
  root 'items#index'
  resources :items do
    resources :messages, only: [:new, :create]
    post 'order', on: :member
  end
  resources :users, only: [:show, :update]
  resources :cards, only: [:new, :create]
end
