# frozen_string_literal: true
require File.expand_path('../config/application', __FILE__)

require 'solr_wrapper/rake_task'
require 'rspec/core/rake_task'

Rails.application.load_tasks

Rake::Task[:default].clear
task default: [:ci]
