Rails.application.routes.draw do
  root to: 'pages#show', id: 'index'
  blacklight_for :catalog
  devise_for :users
  get '/:id' => 'pages#show', as: :page, id: :id
end
