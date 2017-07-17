# frozen_string_literal: true
require File.expand_path('../config/application', __FILE__)

require 'solr_wrapper/rake_task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'sneakers/tasks'

Rails.application.load_tasks

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc 'Run test suite and style checker'
task spec: :rubocop

Rake::Task[:default].clear
task default: [:ci]
