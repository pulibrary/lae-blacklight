# frozen_string_literal: true
require 'json'
require 'iiif/presentation'

module ApplicationHelper
  def image_ids_labels_from_manifest(manifest)
    ids_labels = []
    manifest.sequences.first.canvases.each do |canvas|
      id = canvas.images.first.resource.service['@id']
      ids_labels << [id, canvas['label']]
    end
    ids_labels
  end

  ## This is rather lame, but it gives returns a JSON
  ## structure with images and labels for the iiiF
  ## Jquery plugin
  def image_ids_labels_from_manifest_as_hash(manifest)
    ids_labels = []
    page_number = 0
    manifest.sequences.first.canvases.each do |canvas|
      page_number += 1
      id = canvas.images.first.resource.service['@id']
      label = if canvas['label'].nil?
                "Page #{page_number}"
              else
                canvas['label']
              end
      ids_labels << { 'id' => strip_iiif_server_base_from_id(id), 'label' => label }
    end
    ids_labels
  end

  def strip_iiif_server_base_from_id(id)
    base_url = "http://libimages.princeton.edu/loris2/"
    id.gsub(base_url.to_s, '')
  end

  def all_image_ids_from_from_manifest(manifest)
    ids = []
    manifest.sequences.first.canvases.each do |canvas|
      id = canvas.images.first.resource.service['@id']
      ids << id
    end
    ids
  end

  def facet_for_label(label)
    label = label.singularize
    LABEL_METADATA[label][:facet_field]
  end

  def schema_prop_for_label(label)
    label = label.singularize
    LABEL_METADATA[label][:schema]
  end

  def label_has_facet?(label)
    label = label.singularize
    return false unless LABEL_METADATA.key?(label)
    LABEL_METADATA[label].key?(:facet_field)
  end

  def label_has_schema_prop?(label)
    label = label.singularize
    return false unless LABEL_METADATA.key?(label)
    LABEL_METADATA[label].key?(:schema)
  end

  def facet_query_for_label_and_value(label, value)
    query = { "f[#{facet_for_label(label)}][]" => value }.to_param
    "#{request.protocol}#{request.host_with_port}/catalog?#{query}"
  end

  def doc_path(document)
    "/catalog/#{document['id']}"
  end

  def first_id_from_manfiest(document)
    document['thumbnail_base']
  end

  def retrieve_recent_documents
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr_response = solr.get 'select', params: { qt: "search",
                                                 start: 0,
                                                 rows: 8,
                                                 wt: :ruby,
                                                 index: true,
                                                 sort: 'date_modified desc' }
    solr_response['response']['docs']
  end

  def retrieve_featured_document
    doc_id = random_sample_graphic
    solr = RSolr.connect(url: Blacklight.connection_config[:url])
    solr_response = solr.get 'select', params: { qt: "search",
                                                 q: doc_id,
                                                 start: 0,
                                                 rows: 1,
                                                 wt: :ruby,
                                                 index: true }
    solr_response['response']['docs'][0]
  end

  def render_doc_title(document)
    document['title_display'][0]
  end

  def render_brief_doc_metadata(document)
    bf = {}
    bf[:date] ||= document['date_display']
    bf[:publisher] = document['publisher_display'].first if document.key?('publisher_display')
    bf[:origin] ||= document['geographic_origin_label'].first
    render partial: 'brief_document_metadata', locals: { bf: bf }
  end

  def random_sample_graphic
    image_pids = LAE_CONFIG['featured_objects']
    sample_pid = image_pids.sample
    sample_pid
  end
end
