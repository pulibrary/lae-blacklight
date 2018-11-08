# frozen_string_literal: true
class Reindexer
  attr_reader :collection_name
  def initialize(collection_name: "Latin American Ephemera")
    @collection_name = collection_name
  end

  def index!
    solr_documents.each_slice(500) do |docs|
      solr.add(docs)
    end
  end

  def solr_documents
    jsonld_response = PaginatingJSONLDResponse.new(url: url)
    progressbar = ProgressBar.create(total: jsonld_response.total, format: "%a %e %P% Processed: %c from %C")
    jsonld_response.lazy.map do |jsonld|
      progressbar.increment
      PlumJsonldConverter.new(jsonld: jsonld).output
    end
  end

  def solr
    Blacklight.default_index.connection
  end

  def url
    "#{LAE.config['plum_url']}/catalog.json?f[human_readable_type_ssim][]=Ephemera+Folder&f[ephemera_project_ssim][]=#{collection_name.tr(' ', '+')}"
  end

  class JSONLDPathBuilder
    attr_reader :solr_doc
    def initialize(solr_doc)
      @solr_doc = solr_doc
    end

    def path
      "#{LAE.config['plum_url']}/catalog/#{id}.jsonld"
    end

    def id
      solr_doc["id"]
    end
  end

  class PaginatingJSONLDResponse
    include Enumerable
    attr_reader :url
    def initialize(url:)
      @url = url
    end

    def each
      response = Response.new(url: url, page: 1)
      loop do
        response.docs.each do |doc|
          yield jsonld_for(doc)
        end
        break unless (response = response.next_page)
      end
    end

    def jsonld_for(doc)
      open(JSONLDPathBuilder.new(doc).path).read
    end

    def total
      @total ||= Response.new(url: url, page: 1).total_count
    end

    class Response
      require 'open-uri'
      attr_reader :url, :page
      def initialize(url:, page:)
        @url = url
        @page = page
      end

      def docs
        response["docs"]
      end

      def response
        @response ||= JSON.parse(open("#{url}&page=#{page}").read.force_encoding('UTF-8'))["response"]
      end

      def next_page
        return nil unless response["pages"]["next_page"]
        Response.new(url: url, page: response["pages"]["next_page"])
      end

      def total_count
        response["pages"]["total_count"]
      end
    end
  end
end
