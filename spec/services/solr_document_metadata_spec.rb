# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocumentMetadata do
  let(:metadata) { described_class.new(solr_doc) }
  let(:solr_doc) do
    SolrDocument.new(
      id: "b9e8325e-baf2-45e4-b32c-5e5b3755c8ef",
      geographic_origin_label: ["Venezuela"],
      publisher_display: ["Alcaldía del Municipio Caripe"],
      genre_pul_label: ["Pamphlets"],
      page_count: "6",
      geographic_subject_label: ["Venezuela"],
      category: ["Environment and ecology", "Tourism"],
      subject_label: ["National parks and reserves", "Advertising--Tourism"],
      "subject_with_category" => "[{\"subject\":\"National parks and reserves\",\"category\":\"Environment and ecology\"},{\"subject\":\"Advertising--Tourism\",\"category\":\"Tourism\"}]",
      language_label: ["Spanish"],
      rights: "This digital reproduction is intended to support research, teaching, and private study. Users are responsible for determining any copyright questions",
      height_in_cm: "25",
      width_in_cm: "11",
      local_identifier: "xyx123",
      box_physical_number: "1",
      physical_number: "2"
    )
  end

  describe "converting index values for display" do
    it "displays width and height as dimensions" do
      expect(metadata.dimensions).to eq "11 cm. × 25 cm"
    end

    it "displays box/folder number as container" do
      expect(metadata.container).to eq "Box 1, Folder 2"
    end

    it "retrieves values from solr_doc" do
      metadata.each do |entry|
        exceptions = ["Dimensions", "Subject", "Container"]
        expect(solr_doc.to_h.values).to include entry['value'] unless exceptions.include? entry['label']
      end
    end

    it "provides subject and category as hashes" do
      expect(metadata.category_subject_pairs).to contain_exactly(
        { category: "Environment and ecology", subject: "National parks and reserves" },
        { category: "Tourism", subject: "Advertising--Tourism" }
      )
    end
  end
end
