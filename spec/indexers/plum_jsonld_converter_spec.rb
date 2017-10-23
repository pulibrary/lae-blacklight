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
  it "converts the JSON-LD into a suitable solr document" do
    stub_plum_jsonld(record: "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef")
    expect(converter.output.except("ttl", "manifest")).to eq(
      "id" => "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef",
      "pulstore_pid" => "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef",
      "barcode" => "32101086454731",
      "date_uploaded" => "2017-10-18T18:08:59Z",
      "date_modified" => "2017-10-19T21:05:24Z",
      "physical_number" => "193",
      "project_label" => "Latin American Ephemera",
      "contributor" => ["Gobierno Bolivariano de Venezuela"],
      "creator" => "Test Creator",
      "sort_title" => "caripe. jardín turístico de monagas. ",
      "title_es" => "Caripe. Jardín turístico de Monagas. ",
      "title_display" => "Caripe. Jardín turístico de Monagas. ",
      "height_in_cm" => "25",
      "width_in_cm" => "11",
      "page_count" => "6",
      "publisher_es" => ["Alcaldía del Municipio Caripe"],
      "publisher_display" => ["Alcaldía del Municipio Caripe"],
      "rights" => "This digital reproduction is intended to support research, teaching, and private study. Users are responsible for determining any copyright questions", ## Is this right?
      "category" => ["Environment and ecology", "Tourism"],
      "geographic_subject_label" => ["Venezuela"],
      "subject_label" => ["National parks and reserves", "Advertising--Tourism"],
      "genre_pul_label" => ["Pamphlets"],
      "language_label" => ["Spanish"],
      "geographic_origin_label" => ["Venezuela"],
      "box_barcode" => "32101086454731",
      "box_physical_location" => "rcpxr",
      "box_physical_number" => "57", ## MISSING
      "thumbnail_base" => "https://libimages1.princeton.edu/loris/figgy_prod/c6%2Fb4%2Fbe%2Fc6b4beb0d65b4d979adcd74ceba30e92%2Fintermediate_file.jp2"
    )
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
