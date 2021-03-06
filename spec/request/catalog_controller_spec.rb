# frozen_string_literal: true
require 'rails_helper'
require 'rdf/turtle'
require 'iiif/presentation'

RSpec.describe CatalogController, type: :request do
  let(:fixture_box_id) { 'puls:00014' }
  let(:doc_ids) { ['004kr', '006tx', '00b84'] }
  let(:solr_xml_string) { IO.read(Rails.root.join('spec', 'fixtures', 'files', 'solr.xml')) }

  before do
    IndexEvent.post_to_solr('<delete><query>*:*</query></delete>')
    IndexEvent.post_to_solr(solr_xml_string)
    Blacklight.default_index.connection.commit
  end

  describe 'rdf services' do
    describe 'gets a catalog record as turtle' do
      it 'responds with 200' do
        get solr_document_path(doc_ids[0], :ttl)
        expect(response.status).to be(200)
      end

      it 'returns parseable turtle' do
        get solr_document_path(doc_ids[1], :ttl)
        expect do
          RDF::Reader.for(:turtle).new(response.body) do |reader|
            reader.each_statement(&:inspect)
          end
        end.not_to raise_error
      end

      it 'has the correct content-type' do
        get solr_document_path(doc_ids[2], :ttl)
        expect(response.headers['Content-Type']).to eq 'text/turtle; charset=utf-8'
      end
    end

    describe 'gets a catalog record as rdfxml' do
      it 'responds with 200' do
        get solr_document_path(doc_ids[0], :rdf)
        expect(response.status).to be(200)
      end

      it 'returns parseable rdf-xml' do
        get solr_document_path(doc_ids[1], :rdf)
        expect do
          RDF::Reader.for(:rdfxml).new(response.body) do |reader|
            reader.each_statement(&:inspect)
          end
        end.not_to raise_error
        expect(response.headers['Content-Type']).to eq 'application/rdf+xml; charset=utf-8'
      end

      it 'has the correct content-type' do
        get solr_document_path(doc_ids[2], :rdf)
        expect(response.headers['Content-Type']).to eq 'application/rdf+xml; charset=utf-8'
      end
    end
  end

  describe 'manifest services' do
    it 'responds with 200' do
      get solr_document_path(doc_ids[0], :jsonld)
      expect(response.status).to be(200)
    end

    it 'returns parseable jsonld that parses as a IIIF Manifest' do
      get solr_document_path(doc_ids[1], :jsonld)
      expect(IIIF::Service.parse(response.body).class).to be IIIF::Presentation::Manifest
      expect(response.headers['Content-Type']).to eq 'application/ld+json; charset=utf-8'
    end

    it 'has the correct content-type' do
      get solr_document_path(doc_ids[2], :jsonld)
      expect(response.headers['Content-Type']).to eq 'application/ld+json; charset=utf-8'
    end
  end
end
