# frozen_string_literal: true
require 'rails_helper'
require 'vcr'

RSpec.describe Reindexer do
  vcr_options = {
    record: :new_episodes, # See https://www.relishapp.com/vcr/vcr/v/1-6-0/docs/record-modes
    cassette_name: 'reindexer',
    serialize_with: :json
  }
  let(:reindexer) { described_class.new }
  let(:solr) { Blacklight.default_index.connection }
  it "pulls in all objects from Solr and indexes them", vcr: vcr_options do
    reindexer.index!
    expect(solr.get("select", params: { q: "Test Folder 1" })["response"]["numFound"]).to eq 1
  end
end
