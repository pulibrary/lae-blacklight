require 'rails_helper'
require 'rdf/turtle'
require 'iiif/presentation'

# Request specs for testing the LaeExportExtension

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == 'ASCII-8BIT' ||
    !http_message.body.valid_encoding?
  end
end

vcr_options = {
  record: :new_episodes, # See https://www.relishapp.com/vcr/vcr/v/1-6-0/docs/record-modes
  serialize_with: :json
}

RSpec.describe CatalogController, type: :request, vcr: vcr_options do

  let(:fixture_box_id) { 'puls:00014' }
  let(:doc_ids) { ['004kr', '006tx', '00b84'] }
  let(:solr_xml_string) { IO.read(File.join(Rails.root, 'spec/fixtures/files/solr.xml')) }

  before do
    IndexEvent.post_to_solr('<delete><query>*:*</query></delete>')
    IndexEvent.post_to_solr(solr_xml_string)
  end

  describe 'rdf services' do

    describe 'gets a catalog record as turtle' do

      it 'responds with 200' do
        get catalog_path(doc_ids[0], :ttl)
        expect(response.status).to be(200)
      end

      it 'returns parseable turtle' do
        get catalog_path(doc_ids[1], :ttl)
        expect {
          RDF::Reader.for(:turtle).new(response.body) do |reader|
            reader.each_statement { |s| s.inspect }
          end
        }.to_not raise_error
      end

      it 'has the correct content-type' do
        get catalog_path(doc_ids[2], :ttl)
        expect(response.headers['Content-Type']).to eq 'text/turtle; charset=utf-8'
      end
    end

    describe 'gets a catalog record as rdfxml' do

      it 'responds with 200' do
        get catalog_path(doc_ids[0], :rdf)
        expect(response.status).to be(200)
      end

      it 'returns parseable rdf-xml' do
        get catalog_path(doc_ids[1], :rdf)
        expect {
          RDF::Reader.for(:rdfxml).new(response.body) do |reader|
            reader.each_statement { |s| s.inspect }
          end
        }.to_not raise_error
        expect(response.headers['Content-Type']).to eq 'application/rdf+xml; charset=utf-8'
      end

      it 'has the correct content-type' do
        get catalog_path(doc_ids[2], :rdf)
        expect(response.headers['Content-Type']).to eq 'application/rdf+xml; charset=utf-8'
      end

    end

  end

  describe 'manifest services' do

    it 'responds with 200' do
      get catalog_path(doc_ids[0], :jsonld)
      expect(response.status).to be(200)
    end

    it 'returns parseable jsonld that parses as a IIIF Manifest' do
      get catalog_path(doc_ids[1], :jsonld)
      expect(IIIF::Service.parse(response.body).class).to be IIIF::Presentation::Manifest
      expect(response.headers['Content-Type']).to eq 'application/ld+json; charset=utf-8'
    end

    it 'has the correct content-type' do
      get catalog_path(doc_ids[2], :jsonld)
      expect(response.headers['Content-Type']).to eq 'application/ld+json; charset=utf-8'
    end

  end

end
