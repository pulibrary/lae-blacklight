# frozen_string_literal: true
class PlumEventProcessor
  class CreateProcessor < Processor
    def process
      return false unless collection_slugs.include?(LAE.config["collection"]["slug"])
      return false unless solr_record["id"]
      index.add(solr_record, params: { softCommit: true })
      true
    end

    def jsonld_url
      manifest_url.gsub("/manifest", ".jsonld")
    end

    def json
      @json ||= open(jsonld_url).read
    end

    def solr_record
      @solr_record ||= PlumJsonldConverter.new(jsonld: json).output
    end
  end
end
