# frozen_string_literal: true
module ThumbnailHelper
  def thumbnail_from_manifest(document, image_options = { height: '400', width: '400' })
    return unless document['thumbnail_base']
    image_tag "#{document['thumbnail_base']}/full/!#{image_options[:height]},#{image_options[:width]}/0/default.png"
  end

  def render_square_thumbnail(document)
    image_tag "#{document['thumbnail_base']}/full/!400,400/0/default.png"
  end

  def render_fullsize_thumbnail(document)
    return unless document.nil?
    image_tag "#{document['thumbnail_base']}/full/!600,600/0/default.jpg"
  end
end
