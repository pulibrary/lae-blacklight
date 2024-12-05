# frozen_string_literal: true
source 'https://rubygems.org'

gem 'bitters', '~> 2.0.0'
gem 'bixby', '~> 5.0'
# Locked to Blacklight 7.24 as 7.25.1 currently breaks range limit
gem 'blacklight', '~> 7.24'
gem 'blacklight-gallery'
gem 'blacklight_range_limit'
gem 'bootstrap', '~> 4.0'
gem 'bourbon', '~> 7.0'
gem 'breakpoint'
gem 'capistrano'
gem 'capistrano-bundler'
gem 'capistrano-passenger'
gem 'capistrano-rails'
gem 'coffee-rails', '~> 5.0.0'
gem "ddtrace", require: "ddtrace/auto_instrument"
gem "devise"
gem "devise-guests"
gem 'devise-i18n'
gem 'faraday'
gem 'faraday-multipart'
gem 'ffi', '>= 1.9.25'
gem 'font-awesome-sass', '~> 4.7.0'
gem "health-monitor-rails", "12.4.1"
gem 'high_voltage', '~> 4.0.0'
gem "honeybadger"
gem 'iiif-presentation'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'json-ld'
gem 'loofah', '>= 2.2.3'
gem "mail_form"
gem "mimemagic"
gem 'modernizr-rails'
gem 'nokogiri', '~> 1.16.0'
gem "openseadragon"
gem "pg"
gem "progressbar"
gem 'pul_uv_rails', github: 'pulibrary/pul_uv_rails', branch: 'main'
gem "puma"
gem 'rack', '>= 2.0.6'
gem 'rails', '~> 7.2.0'
gem 'rails-html-sanitizer', '>= 1.0.4'
gem 'rake', '~> 13.0'
gem 'rdf-rdfxml', '~> 3.0'
gem 'rdf-turtle', '~> 3.0'
gem 'rdf-vocab'
gem 'rsolr'
gem 'rspec-rails'
gem 'rubyzip', '>= 1.2.2'
gem 'sass'
gem 'sass-rails'
gem "simple_form", "5.3.1"
gem 'singularitygs'
gem 'sneakers'
gem 'sprockets', '>= 3.7.2'
gem 'turbolinks'

## Added for Ruby 3.1 support
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", require: false

group :test, :development do
  gem 'bcrypt_pbkdf'
  gem 'byebug'
  gem 'capybara'
  gem 'ed25519'
  gem 'i18n-tasks', '~> 0.9'
  gem 'pry-byebug'
  gem "simplecov", require: false
  gem 'yard'
end

group :development do
  gem 'spring'
  gem 'web-console', '~> 4.0'
end

group :test do
  gem 'rails-controller-testing'
  gem "timecop", "~> 0.9.10"
  gem 'vcr'
  gem 'webmock'
end
