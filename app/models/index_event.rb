# frozen_string_literal: true
require 'rake'
class IndexEvent < ApplicationRecord
  PULSTORE_CONFIG ||= YAML.load_file(Rails.root.join('config', 'pulstore.yml'))

  INDEXING_TASKS =

    class << self
      def record
        event = IndexEvent.new
        event.start = Time.now.utc
        event.success = true
        event.task = Rake.application.top_level_tasks.first if defined?(Rake)
        yield
      rescue StandardError => e
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
      def get_boxes_data(opts = {})
        url = opts.fetch(:url, boxes_url)
        conn = Faraday.new(url) do |c|
          c.use Faraday::Response::RaiseError
          c.adapter Faraday::Adapter::NetHttp
        end
        JSON.parse(conn.get.body)
      end

      def delete_index
        IndexEvent.record do
          puts 'Deleting index' if defined?(Rake)
          solr = RSolr.connect(url: solr_url)
          solr.delete_by_query('*:*')
        end
      end

      def delete_one(id)
        IndexEvent.record do
          puts "Deleting #{id}" if defined?(Rake)
          solr = RSolr.connect(url: solr_url)
          solr.delete_by_id(id)
        end
      end

      def optimize
        IndexEvent.record do
          puts 'Optimizing index' if defined?(Rake)
          solr = RSolr.connect(url: solr_url)
          solr.optimize
        end
      end

      # Options
      #  * box_id
      #  * folder_id
      # Raises exceptions that indicate HTTP problems (from #get_solr_xml)
      def index_resource(opts = {})
        IndexEvent.record do
          IndexEvent.post_to_solr(IndexEvent.get_solr_xml(opts))
        end
      end

      def latest_successful
        IndexEvent.where(task: ["lae:index", "lae:update"], success: true).order('start desc').first
      end

      # Options
      #  * box_id
      #  * folder_id
      def get_solr_xml(opts)
        url = item_url(opts)
        raise 'A box_id or folder_id must be supplied' unless url
        conn = Faraday.new(url) do |c|
          c.use Faraday::Response::RaiseError
          c.adapter Faraday::Adapter::NetHttp
        end
        conn.get.body
      end

      def post_to_solr(xml_str)
        solr = RSolr.connect(url: solr_url)
        solr.update(data: xml_str, headers: { 'Content-Type' => 'text/xml' })
      end

      protected

        def solr_url
          (Blacklight.blacklight_yml[Rails.env]['url']).to_s
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

        def item_url(opts)
          box_id = opts.fetch(:box_id, nil)
          folder_id = opts.fetch(:folder_id, nil)
          return nil unless box_id || folder_id
          if box_id
            puts "Getting Box #{box_id}" if defined?(Rake)
            url = box_url(box_id)
          else
            puts "Getting Folder #{folder_id}" if defined?(Rake)
            url = folder_url(folder_id)
          end

          url
        end
    end
end
