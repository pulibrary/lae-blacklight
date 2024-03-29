# frozen_string_literal: true

# Fetches json search results pages from figgy, and then the jsonld record for
# each result. Formats each record for ingest into solr via PlumJsonldConverter.
class Reindexer
  attr_reader :collection_name, :solr
  def initialize(collection_name: "Latin American Ephemera", solr_url: nil)
    @collection_name = collection_name
    @solr = if solr_url
              RSolr.connect(url: solr_url)
            else
              Blacklight.default_index.connection
            end
  end

  def index!
    errored_documents = []
    solr_documents.each_slice(500) do |docs|
      solr.add(docs)
    rescue StandardError => e
      Rails.logger.warn "Failed to index a document with error: #{e.message}. Adding for individual indexing."
      errored_documents += docs
    end
    run_individual_retries(docs: errored_documents)
  end

  def run_individual_retries(docs:)
    docs.each do |document|
      solr.add(document)
    rescue StandardError => e
      Rails.logger.warn "Failed to index #{document['id']}: #{e.message}"
    end
  end

  def solr_documents
    jsonld_response = PaginatingJSONLDResponse.new(url:)
    progressbar = ProgressBar.create(total: jsonld_response.total, format: "%a %e %P% Processed: %c from %C")
    jsonld_response.lazy.map do |jsonld|
      progressbar.increment
      PlumJsonldConverter.new(jsonld:).output
    end
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
      response = Response.new(url:, page: 1)
      loop do
        response.docs.each do |doc|
          yield jsonld_for(doc)
        end
        break unless (response = response.next_page)
      end
    end

    def jsonld_for(doc)
      URI.open(JSONLDPathBuilder.new(doc).path).read
    end

    def total
      @total ||= Response.new(url:, page: 1).total_count
    end

    class Response
      require 'open-uri'
      attr_reader :url, :page
      def initialize(url:, page:)
        @url = url
        @page = page
      end

      def docs
        response["data"]
      end

      def response
        @response ||= JSON.parse(URI.open("#{url}&page=#{page}").read.force_encoding('UTF-8'))
      end

      def next_page
        return nil unless response["meta"]["pages"]["next_page"]
        Response.new(url:, page: response["meta"]["pages"]["next_page"])
      end

      def total_count
        response["meta"]["pages"]["total_count"]
      end
    end
  end
end
