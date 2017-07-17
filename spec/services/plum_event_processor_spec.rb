# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PlumEventProcessor, vcr: { cassette_name: "plum_events", allow_playback_repeats: true } do
  subject(:processor) { described_class.new(event) }
  let(:event) do
    {
      "id" => id,
      "event" => type,
      "manifest_url" => url,
      "collection_slugs" => collection_slugs
    }
  end
  let(:id) { "sx920fz824" }
  let(:collection_slugs) { [LAE.config["collection"]["slug"]] }
  let(:url) { "https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824/manifest" }
  let(:solr) { Blacklight.default_index.connection }
  before do
    solr.delete_by_id("sx920fz824")
    solr.commit
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
      let(:url) { "https://hydra-dev.princeton.edu/concern/ephemera_box/sx920fz824/manifest" }
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
      output = solr.get("select", params: { q: "id:sx920fz824", qt: "document" })
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
      solr.add(PlumJsonldConverter.new(jsonld: open(url.gsub("/manifest", ".jsonld")).read).output, params: { softCommit: true })

      expect(processor.process).to eq true

      output = solr.get("select", params: { q: "id:sx920fz824", qt: "document" })
      expect(output["response"]["numFound"]).to eq 0
    end
  end
  context "when given an update event" do
    let(:type) { "UPDATED" }
    it "updates that resource" do
      solr.add(PlumJsonldConverter.new(jsonld: open(url.gsub("/manifest", ".jsonld")).read).output, params: { softCommit: true })
      allow(PlumJsonldConverter).to receive(:new).and_return(instance_double(PlumJsonldConverter, output: { id: id, title_display: "Fake Thing" }.stringify_keys))
      allow(solr).to receive(:add).and_call_original

      expect(processor.process).to eq true

      output = solr.get("select", params: { q: "id:sx920fz824", qt: "document" })
      expect(output["response"]["numFound"]).to eq 1
      expect(output["response"]["docs"][0]["title_display"]).to eq ["Fake Thing"]
      expect(solr).to have_received(:add)
    end
    context "when it's no longer accessible" do
      it "deletes it" do
        solr.add(PlumJsonldConverter.new(jsonld: open(url.gsub("/manifest", ".jsonld")).read).output, params: { softCommit: true })
        stub_request(:get, url.gsub("/manifest", ".jsonld")).to_return(body: "{}", headers: { "Content-Type" => "application/json+ld" })

        expect(processor.process).to eq true

        output = solr.get("select", params: { q: "id:sx920fz824", qt: "document" })
        expect(output["response"]["numFound"]).to eq 0
      end
    end
    context "when it's removed from the collection" do
      let(:collection_slugs) { [] }
      it "deletes it" do
        solr.add(PlumJsonldConverter.new(jsonld: open(url.gsub("/manifest", ".jsonld")).read).output, params: { softCommit: true })

        expect(processor.process).to eq true

        output = solr.get("select", params: { q: "id:sx920fz824", qt: "document" })
        expect(output["response"]["numFound"]).to eq 0
      end
    end
  end
end
