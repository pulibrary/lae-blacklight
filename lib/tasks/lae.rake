# frozen_string_literal: true
require 'rsolr'
require 'faraday'
require 'yaml'

namespace :lae do
  task reindex: :environment do
    Reindexer.new.index!
  end

  task index_fixtures: :environment do
    fixture_files = Rails.root.join('spec', 'fixtures', 'files', 'plum_records')
    Dir["#{fixture_files}/*.jsonld"].each do |fn|
      puts "Indexing #{fn}"
      Blacklight.default_index.connection.add(PlumJsonldConverter.new(jsonld: File.new(fn).read).output)
    end
    Blacklight.default_index.connection.commit
  end

  desc 'Delete the ENTIRE existing index'
  task drop_index: :environment do
    IndexEvent.delete_index
  end

  desc 'Delete a single record from the index (supply the id: `id=12345 lae:delete_one`)'
  task delete_one: :environment do
    return IndexEvent.delete_one(ENV['id']) unless ENV['id'].nil?
    raise 'No record id supplied'
  end

  namespace :solr do
    desc 'Posts fixtures to Solr'
    task :index do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      content = File.read('spec/fixtures/files/208_solr_docs.xml')
      solr.update(data: content, headers: { 'Content-Type' => 'text/xml' })
      solr.commit
    end
  end
end
