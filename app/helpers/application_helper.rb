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
    base_url = "https://libimages.princeton.edu/loris/"
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

  def facet_links_for_category_and_subject(hash)
    category = link_to hash[:category], facet_query_for_label_and_value('Category', hash[:category])
    return category if hash[:subject] == hash[:category]
    subject = link_to hash[:subject], facet_query_for_label_and_value('Subjects', hash[:subject])
    return subject if hash[:category].blank?
    "#{category} -- #{subject}".html_safe
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
                                                 fq: ["thumbnail_base:['' TO *]", "title:['' TO *]"],
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
    render partial: 'brief_document_metadata', locals: { bf: }
  end

  def random_sample_graphic
    image_pids = LAE_CONFIG['featured_objects']
    sample_pid = image_pids.sample
    sample_pid
  end

  # Which translations are available for the user to select
  # @return [Hash<String,String>] locale abbreviations as keys and labels as values
  def available_translations
    {
      'en' => 'English',
      'es' => 'Español',
      'pt-BR' => 'Português do Brasil'
    }
  end

  # replace this on resolution of https://github.com/projectblacklight/blacklight/issues/1809
  # I don't know how to write a helper test for this
  def locale_switch_link(language)
    path = request.original_fullpath
    if params.to_unsafe_h.include? 'locale'
      path.gsub(%r{locale=#{I18n.locale}}, "locale=#{language}")
    elsif request.query_parameters.empty?
      path + "?locale=#{language}"
    else
      path + "&locale=#{language}"
    end
  end

  # Generates the URL for the IIIF Manifest (cached in the Solr Document)
  # @see LaeExportExtension#export_as_jsonld
  #
  # @param solr_document_uri [String] the URI for the Solr Document
  # @return [String] the URL to the
  def viewer_data_uri(solr_document_uri)
    uri = URI.parse(solr_document_uri)
    "#{uri.path}.jsonld"
  end

  # if user is using locale via querystring params, make sure it's part of the links on the page
  def link_with_locale(url)
    params.to_unsafe_h.include?('locale') ? "#{url}?locale=#{I18n.locale}" : url
  end

  # Renders a field value based on value type
  # @param entry [Hash]
  # @param value [String, Hash] the value of the field
  # @return [String]
  def metadata_field_value(field, value)
    if value.is_a?(Hash)
      facet_links_for_category_and_subject(value)
    elsif label_has_facet?(field['label'])
      link_to(value, facet_query_for_label_and_value(field['label'], value))
    else
      value
    end
  end
end
