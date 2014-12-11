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
    if LABEL_METADATA.has_key?(label)
      return LABEL_METADATA[label].has_key?(:facet_field)
    else
      return false
    end
  end

  def label_has_schema_prop?(label)
    label = label.singularize
    if LABEL_METADATA.has_key?(label)
      return LABEL_METADATA[label].has_key?(:schema)
    else
      return false
    end
  end

  def facet_query_for_label_and_value(label,value)
    query={"f[#{facet_for_label(label)}][]" => value }.to_param
    "#{request.protocol}#{request.host_with_port}/catalog?#{query}"
  end

  def thumbnail_from_manifest document, image_options = {}
    manifest = IIIF::Service.parse(document['manifest'])
    image_tag "#{document['thumbnail_base']}/full/!200,200/0/default.png"
  end

  def first_id_from_manfiest document, image_options = {}
    #manifest = IIIF::Service.parse(document['manifest'])
    #canvas = manifest.sequences.first.canvases.first
    #id = canvas.images.first.resource.service['@id']
    document['thumbnail_base']
  end
end
