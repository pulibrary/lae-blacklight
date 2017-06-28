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
    data.select{ |box| !box['last_mod_prod_folder'].nil? }.each do |box|
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

  desc 'Copy solr config files to Jetty wrapper'
  task solr2jetty: :environment do
    cp Rails.root.join('solr_conf','solr.xml'), Rails.root.join('jetty','solr')
    cp Rails.root.join('solr_conf','conf','schema.xml'), Rails.root.join('jetty','solr','blacklight-core','conf')
    cp Rails.root.join('solr_conf','conf','solrconfig.xml'), Rails.root.join('jetty','solr','blacklight-core','conf')
    unless File.exists?(Rails.root.join('jetty','solr','blacklight-core','conf','lang'))
      Dir.mkdir(Rails.root.join('jetty','solr','blacklight-core','conf','lang'))
    end
    Dir.glob(Rails.root.join('solr_conf','conf','lang','*')).each do |lang_file|
      cp lang_file, Rails.root.join('jetty','solr','blacklight-core','conf', 'lang')
    end
  end

  desc 'Clear the index and load development fixtures into Solr'
  task load_fixtures: :environment do
    if Rails.env.development?
      begin
        fp = Rails.root.join('spec','fixtures', 'files', '208_solr_docs.xml.gz')
        solr_url = "#{Blacklight.blacklight_yml[Rails.env]['url']}"
        solr = RSolr.connect(url: solr_url)
        solr.delete_by_query('*:*')

        File.open(fp) do |f|
          gz = Zlib::GzipReader.new(f)
          content = gz.read
          solr.update(data: content, headers: { 'Content-Type' => 'text/xml' })
          solr.commit
          gz.close
        end

      rescue Exception => e
        solr.rollback
        puts '***Rolled back Solr***'
        raise e
      end
      solr.commit
      solr.optimize
    else
      STDERR.puts 'This task is only available in the development environment'
    end
  end
end
