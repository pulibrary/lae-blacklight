# frozen_string_literal: true
Rails.application.routes.draw do
  mount HealthMonitor::Engine, at: "/"
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  root to: 'pages#show', id: 'index'
  match '/contacts', to: 'contacts#new', via: 'get'
  resources "contacts", only: [:new, :create]

  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  devise_for :users

  get '/:id' => 'pages#show', as: :page, id: :id
end
