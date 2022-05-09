# frozen_string_literal: true
module FacetsHelper
  # def initial_collapse(display_facet, not_selected)
  #   if display_facet.class == Blacklight::Solr::Response::Facets::FacetItem
  #     not_selected ? 'collapse' : 'collapse in'
  #   else
  #     'facet-values'
  #   end
  # end
  #
  # def facet_value_id(display_facet)
  #   display_facet.respond_to?('value') ? "id=#{display_facet.field.parameterize}-#{display_facet.value.parameterize}" : ""
  # end
  #
  # # TODO: Write specs for this method and refactor.
  # # rubocop:disable CyclomaticComplexity, PerceivedComplexity
  # def pivot_facet_in_params?(field, item)
  #   field = item.field if item&.respond_to?(:field)
  #   value = facet_value_for_facet_item(item)
  #   pivot_in_params = true if params[:f] && params[:f][field] && params[:f][field].include?(value)
  #   unless item.items.blank?
  #     item.items.each { |pivot_item| pivot_in_params = true if pivot_facet_in_params?(pivot_item.field, pivot_item) }
  #   end
  #   pivot_in_params
  # end
  # # rubocop:enable CyclomaticComplexity, PerceivedComplexity
  #
  # ##
  # # Are any facet restrictions for a field in the query parameters?
  # #
  # # @param [String] facet field
  # # @return [Boolean]
  # def facet_field_in_params?(field)
  #   pivot = facet_configuration_for_field(field).pivot
  #   if pivot
  #     pivot_facet_field_in_params?(pivot)
  #   else
  #     params[:f] && params[:f][field]
  #   end
  # end
  #
  # def pivot_facet_field_in_params?(pivot)
  #   in_params = false
  #   pivot.each { |field| in_params = true if params[:f] && params[:f][field] }
  #   in_params
  # end
end
