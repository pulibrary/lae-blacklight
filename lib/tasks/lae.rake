require 'rsolr'
require 'faraday'
require 'yaml'

namespace :lae do

  desc 'Do a complete reindex of the site (dumps the current index and starts over)'
  task index: :environment do
    data = IndexEvent.get_boxes_data
    IndexEvent.delete_index
    data.select{ |box| !box['last_mod_prod_folder'].nil? }.each do |box|
      IndexEvent.index_resource(box_id: box['id'])
    end
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

  # task :do_nothing do
  #   IndexEvent.record { puts 'Used to test IndexEvent' }
  # end

end









