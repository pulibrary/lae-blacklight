# frozen_string_literal: true
class PlumJsonldConverter
  attr_reader :jsonld
  def initialize(jsonld:)
    @jsonld = jsonld
  end

  def output
    return {} unless json["@id"]
    {
      "id" => id,
      "pulstore_pid" => id,
      "barcode" => barcode,
      "date_uploaded" => date_uploaded,
      "date_modified" => date_modified,
      "project_label" => project_label,
      "contributor" => contributor,
      "creator" => creator,
      "sort_title" => sort_title,
      "box_barcode" => box_barcode,
      "box_physical_location" => "rcpxr",
      "category" => category,
      "genre_pul_label" => genre_pul_label,
      "geographic_origin_label" => geo_origin_label,
      "geographic_subject_label" => geo_subject_label,
      "height_in_cm" => height,
      "width_in_cm" => width,
      "page_count" => json["page_count"],
      "language_label" => language_label,
      "publisher_display" => publisher_display,
      "title_display" => title_display,
      "subject_label" => subject_label,
      "subject_with_category" => subject_with_category,
      "publisher_#{postfix}" => publisher_display,
      "title_#{postfix}" => title_display,
      "title" => title_display,
      "ttl" => ttl,
      "manifest" => manifest,
      "thumbnail_base" => thumbnail_base,
      "rights" => rights,
      "physical_number" => physical_number,
      "box_physical_number" => box_physical_number,
      "local_identifier" => local_identifier,
      "earliest_created" => earliest_created,
      "latest_created" => latest_created,
      "date_display" => date_display,
      "date_created" => date_created,
      "description" => description
    }
  end

  private

    def json
      @json ||= JSON.parse(jsonld.dup.force_encoding('UTF-8'))
    end

    def ttl; end

    def id
      json["@id"].split("/").last
    end

    def earliest_created
      return unless date && date.is_a?(Hash)
      Array.wrap(date["begin"]).first
    end

    def latest_created
      return unless date && date.is_a?(Hash)
      Array.wrap(date["end"]).first
    end

    def date_display
      return date_created unless earliest_created && latest_created
      "#{earliest_created}-#{latest_created}"
    end

    def date_created
      return if earliest_created
      Array.wrap(json["date_created"]).first
    end

    def date
      Array.wrap(json["date_range"]).first
    end

    def barcode
      json["barcode"]
    end

    def description
      json["description"]
    end

    def date_uploaded
      DateTime.strptime(json["created"], "%m/%d/%y %I:%M:%S %p %Z").utc.iso8601
    end

    def date_modified
      DateTime.strptime(json["modified"], "%m/%d/%y %I:%M:%S %p %Z").utc.iso8601
    end

    def project_label
      "Latin American Ephemera"
    end

    def contributor
      json["contributor"]
    end

    def creator
      Array(json["creator"]).first
    end

    def sort_title
      Array(json["sort_title"]).first
    end

    def box_barcode
      box["barcode"]
    end

    def box
      Array.wrap(json["memberOf"]).find { |x| x["box_number"].present? } || {}
    end

    def category
      Array.wrap(json["subject"]).select { |x| x["in_scheme"].present? }.map { |x| x["in_scheme"]["pref_label"] }
    end

    def local_identifier
      Array.wrap(json["local_identifier"]).first
    end

    def genre_pul_label
      Array.wrap(json["dcterms_type"]).map { |x| x["pref_label"] }
    end

    def geo_origin_label
      Array.wrap(json["origin_place"]).map do |value|
        if value.is_a?(Hash)
          value["pref_label"]
        else
          value
        end
      end
    end

    def geo_subject_label
      Array.wrap(json["coverage"]).map do |value|
        if value.is_a?(Hash)
          value["pref_label"]
        else
          value
        end
      end
    end

    def height
      Array.wrap(json["height"]).first
    end

    def width
      Array.wrap(json["width"]).first
    end

    def language_label
      Array.wrap(json["language"]).map { |x| x["pref_label"] }
    end

    def publisher_display
      Array.wrap(json["publisher"])
    end

    def title_display
      Array.wrap(json["title"]).first
    end

    def subject_label
      Array.wrap(json["subject"]).map { |x| x["pref_label"] }
    end

    def subject_with_category
      JSON.generate(
        Array.wrap(json["subject"]).map do |x|
          unless x["in_scheme"]
            Rails.logger.warn("Data inconsistency: #{id} has subject #{x['pref_label']} with no category")
          end
          { "subject": x["pref_label"],
            "category": x["in_scheme"] ? x["in_scheme"]["pref_label"] : '' }
        end
      )
    end

    def postfix
      if json["language"].present? && json["language"].first["exact_match"]
        lang_lookup[json["language"].first["exact_match"]["@id"]]
      else
        "en"
      end
    end

    def lang_lookup
      {
        "http://id.loc.gov/vocabulary/iso639-1/es" => "es",
        "http://id.loc.gov/vocabulary/iso639-1/pt" => "pt",
        "http://id.loc.gov/vocabulary/iso639-1/en" => "en"
      }
    end

    def manifest
      @manifest ||=
        begin
          result = open("#{json['@id'].gsub('catalog', 'concern/ephemera_folders')}/manifest")
          if result.success?
            result.body.force_encoding('UTF-8')
          else
            "{}"
          end
        rescue OpenURI::HTTPError
          "{}"
        end
    end

    def open(url)
      Faraday.get(url)
    end

    def manifest_json
      @manifest_json ||= JSON.parse(manifest.dup.force_encoding('UTF-8'))
    end

    def thumbnail_base
      return nil unless manifest_json["thumbnail"]
      manifest_json["thumbnail"]["service"]["@id"]
    end

    def rights
      "This digital reproduction is intended to support research, teaching, and private study. Users are responsible for determining any copyright questions"
    end

    def physical_number
      json["folder_number"]
    end

    def box_physical_number
      box["box_number"]
    end
end
