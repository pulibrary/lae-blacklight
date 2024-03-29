# frozen_string_literal: true
require 'open-uri'
class PlumEventProcessor
  class CreateProcessor < Processor
    def process
      return false unless collection_slugs.include?(LAE.config["collection"]["slug"])
      return false unless solr_record["id"]
      index.add(solr_record)
      true
    end

    def jsonld_url
      manifest_url.gsub("/manifest", ".jsonld").gsub("concern/ephemera_folders", "catalog")
    end

    def json
      @json ||=
        begin
          URI.open(jsonld_url).read
        rescue OpenURI::HTTPError
          '{}'
        end
    end

    def solr_record
      @solr_record ||= PlumJsonldConverter.new(jsonld: json).output
    end
  end
end
