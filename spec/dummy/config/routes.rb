Rails.application.routes.draw do
  devise_for :users

  get 'products', to: 'products#index'
end
