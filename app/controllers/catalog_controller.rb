# -*- encoding : utf-8 -*-
# frozen_string_literal: true
#
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include BlacklightRangeLimit::ControllerOverride
  helper Openseadragon::OpenseadragonHelper

  configure_blacklight do |config|
    config.raw_endpoint.enabled = true
    config.view.masonry(document_component: Blacklight::Gallery::DocumentComponent, icon: Blacklight::Gallery::Icons::MasonryComponent)
    config.index.thumbnail_method = :thumbnail_from_manifest
    # config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    # config.show.partials.insert(0, :openseadragon)
    config.index.display_type_field = 'genre_pul_label_facet'
    config.show.partials = [:show_header, :show_viewer, :show, :show_similar]

    # Get rid of sms, citation and email features
    config.show.document_actions.delete(:sms)
    config.show.document_actions.delete(:citation)
    config.show.document_actions.delete(:email)

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 12
    }

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [12, 24, 48]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    # config.default_document_solr_params = {
    #   :qt => 'document',
    #   # These are hard-coded in the blacklight 'document' requestHandler
    #   :fl => '*',
    #   :rows => 1,
    #   :q => '{!raw f=id v=$id}'
    # }

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    # config.index.display_type_field = 'genre_pul_label'

    # Change the order or the partials for results on the index page
    # config.index.partials = [:thumbnail, :index_header, :index]

    # solr field configuration for document/show views
    config.show.title_field = 'title_display'

    # config.show.document_actions.sms_action

    # config.show.display_type_field = 'genre_pul_label'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field 'genre_pul_label_facet', label: 'Genre'
    config.add_facet_field 'date_created_facet', label: 'Date Created', **default_range_config
    config.add_facet_field 'geographic_origin_label_facet', label: 'Geographic Origin'
    config.add_facet_field 'category_subject_facet', label: 'Subjects', pivot: ['category_facet', 'subject_label_facet'], collapsing: true
    config.add_facet_field 'geographic_subject_label_facet', label: 'Geographic Subject'
    config.add_facet_field 'language_label_facet', label: 'Language'
    config.add_facet_field 'category_facet', label: 'Category', show: false
    config.add_facet_field 'subject_label_facet', label: 'Subject', show: false

    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #    :years_5 => { label: 'within 5 Years', :fq => "pub_date:[#{Time.now.year - 5 } TO *]" },
    #    :years_10 => { label: 'within 10 Years', :fq => "pub_date:[#{Time.now.year - 10 } TO *]" },
    #    :years_25 => { label: 'within 25 Years', :fq => "pub_date:[#{Time.now.year - 25 } TO *]" }
    # }

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    # config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'geographic_origin_label', label: 'Geographic Origin'
    config.add_index_field 'publisher_display', label: 'Publisher', separator_options: { words_connector: '<br/>', two_words_connector: '<br/>', last_word_connector: '<br/>' }
    config.add_index_field 'date_display', label: 'Date'

    # Solr fields to be displayed in the show (single result) view
    # The ordering of the field names is the order of the display

    # None! All are drawn from the Manifest

    # config.add_show_field 'creator', label: 'Creator'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        'spellcheck.dictionary': 'title',
        qf: '${title_qf}',
        pf: '${title_pf}'
      }
    end

    config.add_search_field('creator_publisher') do |field|
      field.solr_parameters = {
        'spellcheck.dictionary': 'creator',
        qf: '${creator_qf}',
        pf: '${creator_pf}'
      }
    end

    config.add_search_field('subject') do |field|
      field.solr_parameters = {
        'spellcheck.dictionary': 'subject',
        qf: '${subject_qf}',
        pf: '${subject_pf}'
      }
    end

    # # Specifying a :qt only to show it's possible, and so our internal automated
    # # tests can test it. In this case it's the same as
    # # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    # config.add_search_field('subject') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
    #   field.qt = 'search'
    #   field.solr_local_parameters = {
    #     :qf => '$subject_qf',
    #     :pf => '$subject_pf'
    #   }
    # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'relevance', field: 'score desc, sort_title asc'
    config.add_sort_field 'title', field: 'sort_title asc'
    config.add_sort_field 'recently_added', field: 'date_modified desc'
    config.add_sort_field 'date_created_oldest', field: 'date_numsort asc, sort_title asc'
    config.add_sort_field 'date_created_newest', field: 'date_numsort desc, sort_title asc'
    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  rescue_from Blacklight::Exceptions::RecordNotFound, with: :invalid_document_id_error

  def invalid_document_id_error(exception)
    search_service = search_service_class.new(config: blacklight_config, user_params: { search_field: 'local_identifier', q: params[:id] })
    @response, @document = search_service.search_results
    if @document.first && @document.length == 1
      redirect_to solr_document_path(@document.first.id)
      return
    end
    super
  end
end
