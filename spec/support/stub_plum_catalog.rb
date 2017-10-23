# frozen_string_literal: true
module PlumStubbing
  def stub_plum_catalog(records:)
    records.each do |record|
      stub_plum_jsonld(record: record)
    end
    stub_request(:get, "https://figgy.princeton.edu/catalog.json?f[human_readable_type_ssim][]=Ephemera+Folder&f[ephemera_project_ssim][]=Latin+American+Ephemera&page=1")
      .to_return(
        body:
        {
          response:
          {
            docs: records.map do |record|
              JSON.parse(file_fixture("plum_records/#{record}.json").read)
            end,
            facets: [
            ],
            pages: {
              current_page: 1,
              next_page: nil,
              prev_page:  nil,
              total_pages: 1,
              limit_value: records.length,
              offset_value: 0,
              total_count: records.length,
              first_page?: true,
              last_page?: true
            }
          }
        }.to_json
      )
  end

  def stub_plum_jsonld(record:)
    stub_request(:get, "https://figgy.princeton.edu/catalog/#{record}.jsonld")
      .to_return(
        body: file_fixture("plum_records/#{record}.jsonld").read
      )
    stub_request(:get, "https://figgy.princeton.edu/concern/ephemera_folders/#{record}/manifest")
      .to_return(
        body: file_fixture("plum_records/#{record}.manifest.json").read
      )
  end
end

RSpec.configure do |config|
  config.include PlumStubbing
end
