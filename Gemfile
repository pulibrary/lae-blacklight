source 'https://rubygems.org'
gem 'bundler', '>= 1.7.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'

# Use SCSS for stylesheets
gem 'sass-rails'
gem 'compass-rails', '~> 3.0.2'
gem 'breakpoint'
gem 'singularitygs'
gem 'bourbon', '~> 4.2.7'
gem 'bitters', '~> 1.2.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'pul_uv_rails', git: 'https://github.com/pulibrary/pul_uv_rails.git', tag: 'v1.7.27'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'blacklight', '~> 6.10'
gem 'blacklight-gallery', '~> 0.4'
gem 'blacklight_range_limit', '~> 6.1'

gem 'iiif-presentation'

gem 'modernizr-rails'
gem 'font-awesome-sass'

gem "mail_form"
gem "simple_form"

gem 'mysql2', '>= 0.3.13', "< 0.4.0"

# Use Capistrano for deployment
gem 'capistrano', '~> 3.4.0'
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'capistrano-passenger'

gem "devise"
gem "devise-guests", "~> 0.3"

gem 'rsolr'
gem 'faraday'

gem 'rdf-rdfxml', github: 'ruby-rdf/rdf-rdfxml', branch: :develop
gem 'rdf-turtle', '~> 2.2.0'
gem 'rdf-vocab'

# Rails engine for static pages.
gem 'high_voltage', '~> 3.0.0'
gem 'solr_wrapper', '~> 0.22'

gem 'rspec-rails', '~> 3.5.0'
  
group :test, :development do
  gem 'coveralls', require: false
  gem 'capybara'
  gem 'byebug'
  gem 'pry-byebug'
end

group :development do
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'vcr', '~> 2.9.3'
  gem 'webmock'
  gem 'rails-controller-testing'
end
