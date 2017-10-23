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
      width_in_cm: "11"
    )
  end

  describe "converting index values for display" do
    it "displays width and height as dimensions" do
      # TODO either both should have a period or neither should, right?
      expect(metadata.dimensions).to eq "11 cm. × 25 cm"
    end

    it "retrieves values from solr_doc" do
      metadata.each do |entry|
        exceptions = ["Dimensions", "Subjects"]
        unless exceptions.include? entry['label']
          expect(solr_doc.to_h.values).to include entry['value']
        end
      end
    end

    it "renders subject and category as facet links" do
      expect(metadata.rendered_category_subject).to contain_exactly(
        "Environment and ecology -- National parks and reserves", "Tourism -- Advertising--Tourism"
      )
    end
  end
end
