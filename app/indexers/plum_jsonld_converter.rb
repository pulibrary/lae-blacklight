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
      "publisher_#{postfix}" => publisher_display,
      "title_#{postfix}" => title_display,
      "ttl" => ttl,
      "manifest" => manifest,
      "thumbnail_base" => thumbnail_base,
      "rights" => rights,
      "physical_number" => physical_number,
      "box_physical_number" => box_physical_number
    }
  end

  private

    def json
      @json ||= JSON.parse(jsonld)
    end

    def ttl; end

    def id
      json["@id"].split("/").last
    end

    def barcode
      json["barcode"]
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
      json["memberOf"].find { |x| x["box_number"].present? } || []
    end

    def category
      json["subject"].select { |x| x["in_scheme"].present? }.map { |x| x["in_scheme"]["pref_label"] }
    end

    def genre_pul_label
      json["dcterms_type"].map { |x| x["pref_label"] }
    end

    def geo_origin_label
      json["origin_place"].map do |value|
        if value.is_a?(Hash)
          value["pref_label"]
        else
          value
        end
      end
    end

    def geo_subject_label
      json["coverage"].map do |value|
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
      json["language"].map { |x| x["pref_label"] }
    end

    def publisher_display
      json["publisher"]
    end

    def title_display
      Array.wrap(json["title"]).first
    end

    def subject_label
      json["subject"].map { |x| x["pref_label"] }
    end

    def postfix
      lang_lookup[json["language"].first["exact_match"]["@id"]] || "en"
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
          open("#{json['@id'].gsub('catalog', 'concern/ephemera_folders')}/manifest")
        rescue OpenURI::HTTPError
          "{}"
        end
    end

    def open(url)
      Faraday.get(url).body
    end

    def manifest_json
      @manifest_json ||= JSON.parse(manifest)
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
