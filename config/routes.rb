Rails.application.routes.draw do
  root to: 'pages#show', id: 'index'
  match '/contacts', to: 'contacts#new', via: 'get'
  resources "contacts", only: [:new, :create]
  blacklight_for :catalog
  devise_for :users
  get '/:id' => 'pages#show', as: :page, id: :id
end
