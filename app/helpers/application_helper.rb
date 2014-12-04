require 'json'
require 'iiif/presentation'

module ApplicationHelper

  def iiif_image_list(document)  
    obj = IIIF::Service.parse(document[:manifest])
    
    self.extract_iiif_ids(obj)
  end

  def extract_iiif_ids(obj)
    ids = []
    obj.sequences.first.canvases.each do |canvas|
      ids << canvas.images.first.resource.service['@id']
    end
    return ids
  end

end
