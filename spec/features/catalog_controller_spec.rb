# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :feature do
  let(:fixture_box_id) { 'puls:00014' }
  let(:doc_ids) { ['004kr', '006tx', '00b84'] }
  let(:solr_xml_string) { IO.read(Rails.root.join('spec', 'fixtures', 'files', 'solr.xml')) }

  before do
    IndexEvent.post_to_solr('<delete><query>*:*</query></delete>')
    IndexEvent.post_to_solr(solr_xml_string)
    # prevent intermittent test failures by committing the index before they run
    Blacklight.default_index.connection.commit
  end

  feature 'cite this' do
    scenario 'should not be an option on catalog#show pages' do
      visit "/catalog/#{doc_ids[0]}"
      expect(page.assert_no_selector('#citationLink')).to be_truthy
    end
  end

  feature 'sms this' do
    scenario 'should not be an option on catalog#show pages' do
      visit "/catalog/#{doc_ids[1]}"
      expect(page.assert_no_selector('#smsLink')).to be_truthy
    end
  end

  feature 'email this' do
    scenario 'should not be an option on catalog#show pages' do
      visit "/catalog/#{doc_ids[2]}"
      expect(page.assert_no_selector('#emailLink')).to be_truthy
    end
  end

  feature 'container display' do
    scenario 'should be displayed on catalog#show pages' do
      visit "/catalog/004kr"
      expect(page).to have_selector 'dd.blacklight-container', text: 'Box 1, Folder 131'
    end
  end

  feature 'rescue 404s with local_identifier lookup' do
    let(:solr) { Blacklight.default_index.connection }
    let(:new_id) { "fec7bb63-a5e1-4caf-be57-c14d41c8db43" }
    let(:old_id) { "34w4m" }

    before do
      VCR.turn_off!

      fixture_files = Rails.root.join('spec', 'fixtures', 'files', 'plum_records')
      stub_request(:get, "https://figgy.princeton.edu/concern/ephemera_folders/#{new_id}/manifest")
        .to_return(
          body: File.new("#{fixture_files}/#{new_id}.manifest.json").read,
          headers: {
            'Content-Type' => "application/json"
          }
        )
      solr.add(PlumJsonldConverter.new(jsonld: File.new("#{fixture_files}/#{new_id}.jsonld").read).output)
      solr.commit
    end
    after do
      VCR.turn_on!
    end

    it "looks up the new id by local_identifier and redirects to it" do
      visit "/catalog/#{old_id}"
      expect(page.current_path).to eq "/catalog/#{new_id}"
    end
  end

  feature 'field labels' do
    it "shows creator label" do
      visit "/catalog/004kr"
      expect(page).to have_selector 'dt.blacklight-creator', text: 'Creator:'
      expect(page).to have_selector 'dt.blacklight-series', text: 'Series:'
      expect(page).to have_selector 'dt.blacklight-provenance', text: 'Provenance:'
    end
  end
end
