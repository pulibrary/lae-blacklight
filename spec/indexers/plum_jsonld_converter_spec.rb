# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PlumJsonldConverter do
  subject(:converter) { described_class.new(jsonld: jsonld) }
  let(:jsonld) { file_fixture("plum_records/b9e8325e-baf2-45e4-b32c-5e5b3755c8ef.jsonld").read }
  before do
    VCR.turn_off!
  end
  after do
    VCR.turn_on!
  end
  context "with valid data" do
    let(:logger) { double }
    let(:id) { "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef" }
    before do
      allow(Rails).to receive(:logger).and_return(logger)
    end
    it "converts the JSON-LD into a suitable solr document" do
      stub_plum_jsonld(record: "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef")
      expect(logger).to receive(:warn).with("Data inconsistency: #{id} has subject Biodiversity with no category")
      expect(converter.output.except("ttl", "manifest")).to eq(
        "id" => id,
        "pulstore_pid" => "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef",
        "barcode" => "32101086454731",
        "date_uploaded" => "2017-10-18T18:08:59Z",
        "date_modified" => "2017-10-19T21:05:24Z",
        "physical_number" => "193",
        "project_label" => "Latin American Ephemera",
        "provenance" => "Test Provenance",
        "contributor" => ["Gobierno Bolivariano de Venezuela"],
        "creator" => "Test Creator",
        "series" => "Test Series",
        "sort_title" => "caripe. jardín turístico de monagas. ",
        "title" => "Caripe. Jardín turístico de Monagas. ",
        "title_es" => "Caripe. Jardín turístico de Monagas. ",
        "title_display" => "Caripe. Jardín turístico de Monagas. ",
        "height_in_cm" => "25",
        "width_in_cm" => "11",
        "local_identifier" => "3cff0",
        "page_count" => "6",
        "publisher_es" => ["Alcaldía del Municipio Caripe"],
        "publisher_display" => ["Alcaldía del Municipio Caripe"],
        "rights" => "This digital reproduction is intended to support research, teaching, and private study. Users are responsible for determining any copyright questions", ## Is this right?
        "category" => ["Environment and ecology", "Tourism"],
        "geographic_subject_label" => ["Venezuela"],
        "subject_label" => ["National parks and reserves", "Advertising--Tourism", "Biodiversity"],
        "subject_with_category" => "[{\"subject\":\"National parks and reserves\",\"category\":\"Environment and ecology\"},{\"subject\":\"Advertising--Tourism\",\"category\":\"Tourism\"},{\"subject\":\"Biodiversity\",\"category\":\"\"}]",
        "genre_pul_label" => ["Pamphlets"],
        "language_label" => ["Spanish"],
        "geographic_origin_label" => ["Venezuela"],
        "box_barcode" => "32101086454731",
        "box_physical_location" => "rcpxr",
        "box_physical_number" => "57", ## MISSING
        "thumbnail_base" => "https://libimages1.princeton.edu/loris/figgy_prod/c6%2Fb4%2Fbe%2Fc6b4beb0d65b4d979adcd74ceba30e92%2Fintermediate_file.jp2",
        "earliest_created" => "2004",
        "latest_created" => "2012",
        "date_display" => "2004-2012",
        "date_created" => nil,
        "description" => ["Test Description"],
        "collections_label" => []
      )
    end
  end
  context "when there's collections" do
    let(:jsonld) { file_fixture("plum_records/986ecdfc-7a39-4511-9412-1d5e6edaeaee.jsonld").read }
    it "indexes collections" do
      stub_plum_jsonld(record: "986ecdfc-7a39-4511-9412-1d5e6edaeaee")

      output = converter.output

      expect(output["collections_label"]).to eq ["Tourism in Cuba"]
    end
  end
  context "when there's no subject" do
    let(:jsonld) { file_fixture("plum_records/1b910c5c-a4d1-449f-b663-781dc8541c6f.jsonld").read }
    it "works" do
      stub_plum_jsonld(record: "1b910c5c-a4d1-449f-b663-781dc8541c6f")
      expect { converter.output }.not_to raise_error
    end
  end
  context "when there's no box" do
    let(:jsonld) { file_fixture("plum_records/1b910c5c-a4d1-449f-b663-781dc8541c6f-boxless.jsonld").read }
    it "works" do
      stub_plum_jsonld(record: "1b910c5c-a4d1-449f-b663-781dc8541c6f-boxless")
      expect { converter.output }.not_to raise_error
    end
  end
  context "when there's no earliest/latest" do
    let(:jsonld) { file_fixture("plum_records/a520829e-5cbd-4bff-8e0e-c05fbd6ed979.jsonld").read }
    it "converts date when there's no earliest/latest" do
      stub_plum_jsonld(record: "a520829e-5cbd-4bff-8e0e-c05fbd6ed979")
      expect(converter.output["date_display"]).to eq "2014"
      expect(converter.output["date_created"]).to eq "2014"
    end
  end
  context "when there's no valid manifest" do
    before do
      stub_plum_jsonld(record: "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef", success: false)
    end
    it "works, but doesn't set the thumbnail" do
      output = converter.output
      expect(output["thumbnail_base"]).to eq nil
    end
  end
end
