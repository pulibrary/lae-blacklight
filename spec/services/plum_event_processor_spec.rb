# frozen_string_literal: true
require 'rails_helper'
require 'open-uri'

RSpec.describe PlumEventProcessor do
  subject(:processor) { described_class.new(event) }
  let(:event) do
    {
      "id" => id,
      "event" => type,
      "manifest_url" => url,
      "collection_slugs" => collection_slugs
    }
  end
  let(:id) { "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef" }
  let(:collection_slugs) { [LAE.config["collection"]["slug"]] }
  let(:url) { "https://figgy.princeton.edu/concern/ephemera_folders/b9e8325e-baf2-45e4-b32c-5e5b3755c8ef/manifest" }
  let(:solr) { Blacklight.default_index.connection }
  before do
    stub_plum_jsonld(record: "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef")
    VCR.turn_off!
    solr.delete_by_id("sx920fz824")
    solr.commit
  end
  after do
    VCR.turn_on!
  end
  context "when given an unknown event" do
    let(:type) { "AWFULBADTHINGSHAPPENED" }
    it "returns false" do
      expect(processor.process).to eq false
    end
  end
  context "when given a creation event" do
    let(:type) { "CREATED" }
    context "and it's not for a folder" do
      let(:url) { "https://figgy.princeton.edu/concern/ephemera_box/sx920fz824/manifest" }
      it "returns false" do
        expect(processor.process).to eq false
      end
    end
    context "and it's for a different collection" do
      let(:collection_slugs) { ["notlae"] }
      it "returns false" do
        expect(processor.process).to eq false
      end
    end
    it "indexes that resource" do
      expect(processor.process).to eq true
      solr.commit
      output = solr.get("select", params: { q: "id:b9e8325e-baf2-45e4-b32c-5e5b3755c8ef", qt: "document" })
      expect(output["response"]["numFound"]).to eq 1
    end
  end
  context "when given a delete event" do
    let(:type) { "DELETED" }
    let(:event) do
      {
        "id" => id,
        "event" => "DELETED",
        "manifest_url" => url
      }
    end
    it "deletes that resource" do
      solr.add(PlumJsonldConverter.new(jsonld: URI.open(url.gsub("/manifest", ".jsonld").gsub("concern/ephemera_folders", "catalog")).read).output, params: { softCommit: true })

      expect(processor.process).to eq true
      solr.commit

      output = solr.get("select", params: { q: "id:b9e8325e-baf2-45e4-b32c-5e5b3755c8ef", qt: "document" })
      expect(output["response"]["numFound"]).to eq 0
    end
  end
  context "when given an update event" do
    let(:type) { "UPDATED" }
    it "updates that resource" do
      solr.add(PlumJsonldConverter.new(jsonld: URI.open(url.gsub("/manifest", ".jsonld").gsub("concern/ephemera_folders", "catalog")).read).output, params: { softCommit: true })
      allow(PlumJsonldConverter).to receive(:new).and_return(instance_double(PlumJsonldConverter, output: { id: id, title_display: "Fake Thing" }.stringify_keys))
      allow(solr).to receive(:add).and_call_original

      expect(processor.process).to eq true
      solr.commit

      output = solr.get("select", params: { q: "id:#{id}", qt: "document" })
      expect(output["response"]["numFound"]).to eq 1
      expect(output["response"]["docs"][0]["title_display"]).to eq ["Fake Thing"]
      expect(solr).to have_received(:add)
    end
    context "when it's no longer accessible" do
      it "deletes it" do
        solr.add(PlumJsonldConverter.new(jsonld: URI.open(url.gsub("/manifest", ".jsonld").gsub("concern/ephemera_folders", "catalog")).read).output, params: { softCommit: true })
        stub_request(:get, url.gsub("/manifest", ".jsonld").gsub("concern/ephemera_folders", "catalog")).to_return(body: "{}", headers: { "Content-Type" => "application/json+ld" }, status: 404)

        expect(processor.process).to eq true
        solr.commit

        output = solr.get("select", params: { q: "id:#{id}", qt: "document" })
        expect(output["response"]["numFound"]).to eq 0
      end
    end
    context "when it's removed from the collection" do
      let(:collection_slugs) { [] }
      it "deletes it" do
        solr.add(PlumJsonldConverter.new(jsonld: URI.open(url.gsub("/manifest", ".jsonld").gsub("concern/ephemera_folders", "catalog")).read).output, params: { softCommit: true })

        expect(processor.process).to eq true
        solr.commit

        output = solr.get("select", params: { q: "id:#{id}", qt: "document" })
        expect(output["response"]["numFound"]).to eq 0
      end
    end
  end
end
