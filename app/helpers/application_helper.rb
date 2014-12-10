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
end
