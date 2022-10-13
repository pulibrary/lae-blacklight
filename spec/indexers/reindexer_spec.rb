# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Reindexer do
  let(:reindexer) { described_class.new }
  let(:solr) { Blacklight.default_index.connection }
  before do
    VCR.turn_off!
    Blacklight.default_index.connection.delete_by_query('*:*')
    stub_plum_catalog
    stub_plum_jsonld(record: "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef")
  end
  after do
    VCR.turn_on!
  end

  it "pulls in all objects from Solr and indexes them" do
    reindexer.index!
    Blacklight.default_index.connection.commit
    expect(solr.get("select", params: { q: "Caripe. Jardín turístico de Monagas." })["response"]["numFound"]).to eq 1
  end

  context "when initialized with a specific solr url" do
    let(:solr_url) { Blacklight.blacklight_yml["test"]["url"] }
    let(:reindexer) { described_class.new(solr_url: solr_url) }

    it "uses the given url" do
      allow(Blacklight).to receive(:default_index)
      reindexer.index!
      expect(Blacklight).not_to have_received(:default_index)

      other_solr = RSolr.connect(url: solr_url)
      other_solr.commit
      expect(other_solr.get("select", params: { q: "Caripe. Jardín turístico de Monagas." })["response"]["numFound"]).to eq 1
    end
  end

  it "suppresses indexing errors" do
    allow(Blacklight.default_index.connection).to receive(:add).and_raise("Something broke")
    allow(Rails.logger).to receive(:warn).and_call_original

    expect { reindexer.index! }.not_to raise_error

    expect(Rails.logger).to have_received(:warn).with("Failed to index a document with error: Something broke. Adding for individual indexing.")
    expect(Rails.logger).to have_received(:warn).with("Failed to index b9e8325e-baf2-45e4-b32c-5e5b3755c8ef: Something broke")
    # Ensure it does an individual add for each failed record.
    expect(Blacklight.default_index.connection).to have_received(:add).exactly(2).times
  end
end
