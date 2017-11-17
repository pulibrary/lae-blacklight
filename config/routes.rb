# frozen_string_literal: true
Rails.application.routes.draw do
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

  if Gem.loaded_specs["blacklight"] && Gem.loaded_specs["blacklight"].version >= Gem::Version.new('6.10.1')
    msg = "\n\n!!!WARNING: ensure routes.rb has been checked against latest blacklight update, and increment version on this warning!!!\n\n"
    $stderr.puts msg
    Rails.logger.warn msg
  end
  # Below copied from https://github.com/projectblacklight/blacklight/blob/5f2a3cffcfb05650f3a2331e81fbf15d7530e9fd/config/routes.rb
  # this fixes a bug where search_history page did not load the locale switcher partial, with error
  # ActionView::Template::Error (No route matches {:action=>"index", :controller=>"search_history", :locale=>"en"}):
  get "search_history", to: "search_history#index", as: "search_history"
  delete "search_history/clear", to: "search_history#clear",   as: "clear_search_history"
  post "/catalog/:id/track", to: 'catalog#track', as: 'track_search_context'
end
