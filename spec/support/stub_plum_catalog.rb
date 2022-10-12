# frozen_string_literal: true
module PlumStubbing
  def stub_plum_catalog
    stub_request(:get, "https://figgy.princeton.edu/catalog.json?f[human_readable_type_ssim][]=Ephemera+Folder&f[ephemera_project_ssim][]=Latin+American+Ephemera&page=1")
      .to_return(
        body: file_fixture("catalog-single-record.json").read
      )
  end

  def stub_plum_jsonld(record:, success: true)
    if success
      stub_request(:get, "https://figgy.princeton.edu/catalog/#{record}.jsonld")
        .to_return(
          body: file_fixture("plum_records/#{record}.jsonld").read
        )
      stub_request(:get, "https://figgy.princeton.edu/concern/ephemera_folders/#{record}/manifest")
        .to_return(
          body: file_fixture("plum_records/#{record}.manifest.json").read
        )
    else
      stub_request(:get, "https://figgy.princeton.edu/catalog/#{record}.jsonld")
        .to_return(
          body: "Broken",
          status: 500
        )
      stub_request(:get, "https://figgy.princeton.edu/concern/ephemera_folders/#{record}/manifest")
        .to_return(
          body: "Broken",
          status: 500
        )
    end
  end
end

RSpec.configure do |config|
  config.include PlumStubbing
end
