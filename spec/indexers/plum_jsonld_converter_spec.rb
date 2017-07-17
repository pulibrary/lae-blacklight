# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PlumJsonldConverter do
  subject(:converter) { described_class.new(jsonld: jsonld) }
  let(:jsonld) do
    '{"title":"Test Folder 1","@context":"https://bibdata.princeton.edu/context.json","@id":"https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824","memberOf":[{"@id":"/concern/ephemera_boxes/s8623j062b","@type":"pcdm:Collection","barcode":"00000000000000","label":"Box 1","holding_location":"rcpxr","box_number":"1"},{"@id":"https://hydra-dev.princeton.edu/collections/s8w32r7521","@type":"pcdm:Collection","title":"Latin American Ephemera"}],"edm_rights":{"@id":"http://rightsstatements.org/vocab/NKC/1.0/","@type":"dcterms:RightsStatement","pref_label":"No Known Copyright"},"@type":"pcdm:Object","alternative":["Alternative Title"],"creator":["Test Creator"],"contributor":["Test Contributor"],"publisher":["Test Publisher"],"barcode":"00000000000000","label":"Folder 1","is_part_of":"Latin American Ephemera","coverage":["Spain"],"dcterms_type":[{"@id":"https://hydra-dev.princeton.edu/vocabulary_terms/186","@type":"skos:Concept","pref_label":"Banners","exact_match":{"@id":"http://id.loc.gov/vocabulary/graphicMaterials/tgm000777"}}],"origin_place":["Spain"],"language":[{"@id":"https://hydra-dev.princeton.edu/vocabulary_terms/149","@type":"skos:Concept","pref_label":"Spanish","exact_match":{"@id":"http://id.loc.gov/vocabulary/iso639-1/es"}}],"subject":[{"@id":"https://hydra-dev.princeton.edu/vocabulary_terms/278","@type":"skos:Concept","pref_label":"Agricultural development projects","exact_match":{"@id":"http://id.loc.gov/authorities/subjects/sh85002306"}}],"category":["Agrarian and rural issues"],"description":[],"source":{"@id":null},"related_url":{"@id":null},"height":"10","width":"10","sort_title":["test folder 1"],"page_count":"50","created":"07/07/17 10:51:29 PM UTC","modified":"07/07/17 11:07:26 PM UTC","folder_number":"1"}'
  end
  before do
    allow(converter).to receive(:open).with("https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824/manifest").and_return(
      '{"@context":"http://iiif.io/api/presentation/2/context.json","@id":"https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824/manifest","@type":"sc:Manifest","label":["Test Folder 1"],"viewingHint":"individuals","viewingDirection":"left-to-right","sequences":[{"@id":"https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824/manifest/sequence/normal","@type":"sc:Sequence","canvases":[{"@id":"https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824/manifest/canvas/st722hc03g","@type":"sc:Canvas","label":"color-landscape.tif","images":[{"@id":"https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824/manifest/annotation/st722hc03g-image","@type":"oa:Annotation","motivation":"sc:painting","resource":{"@id":"https://libimages1.princeton.edu/loris/plum/st%2F72%2F2h%2Fc0%2F3g-intermediate_file.jp2/full/!600,600/0/default.jpg","@type":"dctypes:Image","format":"image/jpeg","width":287,"height":200,"service":{"@context":"http://iiif.io/api/image/2/context.json","@id":"https://libimages1.princeton.edu/loris/plum/st%2F72%2F2h%2Fc0%2F3g-intermediate_file.jp2","profile":"http://iiif.io/api/image/2/level2.json"}},"on":"https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824/manifest/canvas/st722hc03g"}],"width":287,"height":200}],"viewingHint":"individuals"}],"metadata":[{"label":"Creator","value":["Test Creator"]},{"label":"Contributors","value":["Test Contributor"]},{"label":"Published/Created","value":["Test Publisher"]},{"label":"Subject","value":["278"]},{"label":"Language","value":["149"]},{"label":"Alternative title","value":["Alternative Title"]},{"label":"Barcode","value":"00000000000000"},{"label":"Folder number","value":"1"},{"label":"Page count","value":["50"]},{"label":"Geographic origin","value":["Spain"]},{"label":"Genre","value":["Banners"]},{"label":"Geo subject","value":["Spain"]},{"label":"Collection","value":["Box Number 1","Latin American Ephemera"]}],"thumbnail":{"@id":"https://libimagestest.princeton.edu/loris/plum/st%2F72%2F2h%2Fc0%2F3g-intermediate_file.jp2/full/!200,150/0/default.jpg","service":{"@context":"http://iiif.io/api/image/2/context.json","@id":"https://libimagestest.princeton.edu/loris/plum/st%2F72%2F2h%2Fc0%2F3g-intermediate_file.jp2","profile":"http://iiif.io/api/image/2/level2.json"}},"seeAlso":{"@id":"https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824.jsonld","format":"application/ld+json"}}'
    )
  end
  it "converts the JSON-LD into a suitable solr document" do
    expect(converter.output.except("ttl", "manifest")).to eq(
      "id" => "sx920fz824",
      "pulstore_pid" => "sx920fz824",
      "barcode" => "00000000000000",
      "date_uploaded" => "2017-07-07T22:51:29Z",
      "date_modified" => "2017-07-07T23:07:26Z",
      "physical_number" => "1", ## MISSING
      "project_label" => "Latin American Ephemera",
      "contributor" => ["Test Contributor"],
      "creator" => "Test Creator",
      "sort_title" => "test folder 1",
      "title_es" => "Test Folder 1",
      "title_display" => "Test Folder 1",
      "height_in_cm" => "10",
      "width_in_cm" => "10",
      "page_count" => "50",
      "publisher_es" => ["Test Publisher"],
      "publisher_display" => ["Test Publisher"],
      "rights" => "This digital reproduction is intended to support research, teaching, and private study. Users are responsible for determining any copyright questions", ## Is this right?
      "category" => ["Agrarian and rural issues"],
      "geographic_subject_label" => ["Spain"],
      "subject_label" => ["Agricultural development projects"],
      "genre_pul_label" => ["Banners"],
      "language_label" => ["Spanish"],
      "geographic_origin_label" => ["Spain"],
      "box_barcode" => "00000000000000",
      "box_physical_location" => "rcpxr",
      "box_physical_number" => "1", ## MISSING
      "thumbnail_base" => "https://libimagestest.princeton.edu/loris/plum/st%2F72%2F2h%2Fc0%2F3g-intermediate_file.jp2"
    )
  end
  context "when there's no valid manifest" do
    before do
      allow(converter).to receive(:open).with("https://hydra-dev.princeton.edu/concern/ephemera_folders/sx920fz824/manifest").and_return("{}")
    end
    it "works, but doesn't set the thumbnail" do
      output = converter.output
      expect(output["thumbnail_base"]).to eq nil
    end
  end
end
