# frozen_string_literal: true
require 'rsolr'
require 'faraday'
require 'yaml'

namespace :lae do
  # TODO: we need an optimize task when we have spellcheck going; that's when
  # the spellcheck index is built (recommended, can be changed to index time but
  # takes a while and we may not want to do it every time.)
  desc 'Do a complete reindex of the site (dumps the current index and starts over)'
  task index: :environment do
    data = IndexEvent.get_boxes_data
    IndexEvent.delete_index
    data.select { |box| !box['last_mod_prod_folder'].nil? }.each do |box|
      IndexEvent.index_resource(box_id: box['id'])
    end
    IndexEvent.optimize
  end

  desc 'Index a Box (`box_id=puls:00014 rake lae:index_box`)'
  task index_box: :environment do
    IndexEvent.index_resource(box_id: ENV['box_id'])
  end

  desc 'Do an incremental index based on the start time of the last index'
  task update: :environment do
    # UNTESTED
    latest_index = IndexEvent.latest_successful

    puts "Last indexing event was `#{latest_index.task}` on #{latest_index.start}"

    boxes = IndexEvent.get_boxes_data.select { |box|
      !box['last_mod_prod_folder'].nil?
    }.select { |box|
      Time.parse(box['last_mod_prod_folder']['time']) > latest_index.start
    }
    if boxes.empty?
      puts 'There is no new data to index'
    else
      boxes.each { |box| IndexEvent.index_resource(box_id: box['id']) }
    end
    IndexEvent.optimize
  end

  desc 'Delete the ENTIRE existing index'
  task drop_index: :environment do
    IndexEvent.delete_index
  end

  desc 'Delete a single record from the index (supply the id: `id=12345 lae:delete_one`)'
  task delete_one: :environment do
    if ENV['id'].nil?
      raise 'No record id supplied'
    else
      IndexEvent.delete_one(ENV['id'])
    end
  end

  namespace :solr do
    desc 'Posts fixtures to Solr'
    task :index do
      solr = RSolr.connect :url => Blacklight.connection_config[:url]
      content = File.read('spec/fixtures/files/208_solr_docs.xml')
      solr.update(data: content, headers: { 'Content-Type' => 'text/xml' })
      solr.commit
    end
  end
end
