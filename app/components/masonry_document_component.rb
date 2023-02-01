# frozen_string_literal: true

class MasonryDocumentComponent < Blacklight::DocumentComponent
  def before_render
    thumbnail(image_options: { class: 'img-thumbnail' }) if thumbnail.blank?
    super
  end

  def render_document_class(*args)
    @view_context.render_document_class(*args)
  end
end
