source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Mixins grids etc for Front-End
gem 'bourbon'
gem 'neat'
gem 'bitters'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'blacklight'
gem 'blacklight-gallery' #, git: 'git://github.com/projectblacklight/blacklight-gallery'
gem "blacklight_range_limit"
gem 'openseadragon', git: 'git://github.com/kevinreiss/openseadragon-rails.git'
gem 'osullivan', github: 'jpstroop/osullivan', tag: 'v0.0.1'

source 'https://rails-assets.org' do
  gem 'rails-assets-font-awesome'
  gem 'rails-assets-modernizr'
end

gem "mail_form"
gem "simple_form"

gem 'mysql2'

# Use Capistrano for deployment
gem 'capistrano', '~> 3.3.5'
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'capistrano-passenger'

gem "devise"
gem "devise-guests", "~> 0.3"

gem 'rsolr', '~> 1.0.10'
gem 'faraday', '~> 0.9.0'

gem 'rdf-rdfxml', '~> 1.1.3'
gem 'rdf-turtle', '~> 1.1.4'

# Rails engine for static pages.
gem 'high_voltage', '~> 2.2.1'

group :test, :development do
  gem 'coveralls', require: false
  gem 'jettywrapper', '~> 1.7'
  gem 'rspec-rails', '~> 3.0'
  gem 'capybara', '~> 2.4.4'
end

group :development do
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'nokogiri', '~> 1.6.5'
  gem 'vcr', '~> 2.9.3'
  gem 'webmock'
end
