# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Reindexer do
  let(:reindexer) { described_class.new }
  let(:solr) { Blacklight.default_index.connection }
  before do
    VCR.turn_off!
    stub_plum_catalog(records: ["b9e8325e-baf2-45e4-b32c-5e5b3755c8ef"])
  end
  after do
    VCR.turn_on!
  end
  it "pulls in all objects from Solr and indexes them" do
    reindexer.index!
    expect(solr.get("select", params: { q: "Caripe. Jardín turístico de Monagas." })["response"]["numFound"]).to eq 1
  end
end
