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
      page_number = page_number + 1
      id = canvas.images.first.resource.service['@id']
      if canvas['label'].nil? 
        label = "Page #{page_number}"
      else 
        label = canvas['label']
      end
      ids_labels << {'id' => strip_iiif_server_base_from_id(id), 'label' => label}
    end
    ids_labels
  end

  def strip_iiif_server_base_from_id(id)
    base_url = "http://libimages.princeton.edu/loris2/"
    id.gsub("#{base_url}", '')
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

  def thumbnail_from_manifest document, image_options = {:height => '400', :width => '400'}
    image_tag "#{document['thumbnail_base']}/full/!#{image_options[:height]},#{image_options[:width]}/0/default.png"
  end

  def render_square_thumbnail document, image_options = {}
    image_tag "#{document['thumbnail_base']}/full/!400,400/0/default.png"
  end

  def render_fullsize_thumbnail document, image_options = {}
    unless document.nil?
      image_tag "#{document['thumbnail_base']}/full/!600,600/0/default.jpg"
    end
  end

  def doc_path(document)
    "/catalog/#{document['id']}"
  end

  def first_id_from_manfiest document, image_options = {}
    document['thumbnail_base']
  end


  ##
  # Render the sidebar partial for a document
  #
  # @param [SolrDocument]
  # @return [String]
  def render_lae_document_sidebar_partial(document = @document)
    render partial: 'show_sidebar'
  end

  def get_recent_documents
    solr = RSolr.connect(Blacklight.connection_config)
    solr_response = solr.get 'select', :params => {:qt => "search", 
                                                   :start => 0, 
                                                   :rows => 8, 
                                                   :wt => :ruby, 
                                                   :index => true,
                                                   :sort => 'date_modified desc' }
    solr_response['response']['docs']
  end

  def get_featured_document
    doc_id = self.random_sample_graphic
    solr = RSolr.connect(Blacklight.connection_config)
    solr_response = solr.get 'select', :params => {:qt => "search",
                                                   :q => doc_id,
                                                   :start => 0, 
                                                   :rows => 1, 
                                                   :wt => :ruby, 
                                                   :index => true,
                                                   }
    solr_response['response']['docs'][0]
  end

  def render_doc_title(document)
    document['title_display'][0]
  end

  def render_brief_doc_metadata(document)
    bf = Hash.new
    bf[:date] ||= document['date_display'] 
    bf[:publisher] = document['publisher_display'].first if document.has_key?('publisher_display')
    bf[:origin] ||= document['geographic_origin_label'].first 
    render partial: 'brief_document_metadata', :locals => { :bf => bf } 
  end

  def random_sample_graphic
    image_pids = LAE_CONFIG['featured_objects']
    sample_pid = image_pids.shuffle[0]
    sample_pid
  end 

end
