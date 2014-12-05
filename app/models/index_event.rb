class IndexEvent < ActiveRecord::Base

  PULSTORE_CONFIG ||= YAML.load_file(File.join(Rails.root, 'config/pulstore.yml'))
  INDEXING_TASKS =

  class << self

    def record
      event = IndexEvent.new
      event.start = Time.now.utc
      event.success = true
      event.task = Rake.application.top_level_tasks.first if defined?(Rake)
      yield
    rescue Exception => e
      event.success = false
      event.error_text = "#{e.class}: #{e.message}"
      STDERR.puts e.message if defined?(Rake)
    ensure
      event.finish = Time.now.utc
      event.save!
    end

    # Raises exceptions that indicate HTTP problems
    # options:
    #   url: Where to get the data from. Default: #boxes_url
    def get_boxes_data(opts={})
      url = opts.fetch(:url, boxes_url)
      conn = Faraday.new(url) do |c|
        c.use Faraday::Response::RaiseError
        c.use Faraday::Adapter::NetHttp
      end
      JSON.parse(conn.get.body)
    end

    def delete_index
      IndexEvent.record do
        puts 'Deleting index' if defined?(Rake)
        solr = RSolr.connect(url: solr_url)
        solr.delete_by_query(['*:*'])
        solr.commit
      end
    end

    def delete_one(id)
      IndexEvent.record do
        puts "Deleting #{id}" if defined?(Rake)
        solr = RSolr.connect(url: solr_url)
        solr.delete_by_id(id)
        solr.commit
      end
    end

    # Options
    #  * box_id
    #  * folder_id
    # Raises exceptions that indicate HTTP problems (from #get_solr_xml)
    def index_resource(opts={})
      IndexEvent.record do
        IndexEvent.post_to_solr(IndexEvent.get_solr_xml(opts))
      end
    end

    def latest_successful
      q = "task in (\"lae:index\", \"lae:update\") and success = true"
      IndexEvent.where(q).order('start desc').first
    end

    # Options
    #  * box_id
    #  * folder_id
    def get_solr_xml(opts)
      box_id = opts.fetch(:box_id, nil)
      folder_id = opts.fetch(:folder_id, nil)
      if [box_id, folder_id].all?(&:nil?)
        raise 'A box_id or folder_id must be supplied'
      end
      url = nil
      if box_id
        puts "Getting Box #{box_id}" if defined?(Rake)
        url = box_url(box_id)
      else
        puts "Getting Folder #{folder_id}" if defined?(Rake)
        url = folder_url(folder_id)
      end
      conn = Faraday.new(url) do |c|
        c.use Faraday::Response::RaiseError
        c.use Faraday::Adapter::NetHttp
      end
      conn.get.body
    end

    def post_to_solr(xml_str)
      solr = RSolr.connect(url: solr_url)
      solr.update(data: xml_str)
      solr.commit
    end

    protected
    def solr_url
      "#{Blacklight.solr_yml[Rails.env]['url']}"
    end

    def boxes_url
      "#{PULSTORE_CONFIG[Rails.env]['url']}/boxes.json"
    end

    def box_url(id)
      "#{PULSTORE_CONFIG[Rails.env]['url']}/boxes/#{id}.xml"
    end

    def folder_url(id)
      "#{PULSTORE_CONFIG[Rails.env]['url']}/folders/#{id}.xml"
    end



  end

end









