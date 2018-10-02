# frozen_string_literal: true
class SolrDocumentMetadata
  attr_reader :document
  def initialize(document)
    @document = document
  end

  # key is used for translation and solr lookup
  # value is method to call on key.
  #   use :solr_lookup to pull from document.
  def fields
    {
      creator: :solr_lookup,
      contributor: :solr_lookup,
      geographic_origin_label: :solr_lookup,
      publisher_display: :solr_lookup,
      date_display: :solr_lookup,
      genre_pul_label: :solr_lookup,
      description: :solr_lookup,
      series: :solr_lookup,
      provenance: :solr_lookup,
      page_count: :solr_lookup,
      dimensions: :dimensions,
      geographic_subject_label: :solr_lookup,
      category_subject_pairs: :category_subject_pairs,
      language_label: :solr_lookup,
      container: :container,
      rights: :solr_lookup
    }
  end

  def each
    fields.each do |key, method|
      next unless send(method, key)
      yield 'label' => I18n.t("metadata.labels.#{key}"), 'value' => send(method, key)
    end
  end

  def solr_lookup(key)
    document[key]
  end

  def container(_key = nil)
    "Box #{document['box_physical_number']}, Folder #{document['physical_number']}"
  end

  def dimensions(_key = nil)
    return unless document['width_in_cm'] && document['height_in_cm']
    "#{document['width_in_cm']} cm. × #{document['height_in_cm']} cm"
  end

  def category_subject_pairs(_key = nil)
    return unless document['subject_with_category']
    JSON.parse(document['subject_with_category']).map do |h|
      { category: h["category"], subject: h["subject"] }
    end
  end
end
