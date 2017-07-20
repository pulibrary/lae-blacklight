# frozen_string_literal: true
class SolrDocumentMetadata
  attr_reader :document
  def initialize(document)
    @document = document
  end

  def fields
    {
      geographic_origin_label: "Origin",
      publisher_display: "Publisher",
      date_display: "Date",
      genre_pul_label: "Item Type",
      page_count: "Page Count",
      geographic_subject_label: "Geographic Subject",
      category: "Category",
      subject_label: "Subjects",
      language_label: "Language",
      # do something for container
      rights: "Rights"
    }
  end

  def each
    fields.each do |solr_key, label|
      next unless document[solr_key]
      yield 'label' => label, 'value' => document[solr_key]
    end
    yield dimensions if dimensions
  end

  def dimensions
    return unless document['width_in_cm'] && document['height_in_cm']
    { 'label' => "Dimensions", 'value' => "#{document['width_in_cm']} cm. × #{document['height_in_cm']} cm" }
  end
end
