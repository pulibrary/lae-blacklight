require 'rails_helper'

RSpec.describe CatalogController, type: :feature do

  let(:fixture_box_id) { 'puls:00014' }
  let(:doc_ids) { ['004kr', '006tx', '00b84'] }
  let(:solr_xml_string) { IO.read(File.join(Rails.root, 'spec/fixtures/files/solr.xml')) }

  before do
    IndexEvent.post_to_solr('<delete><query>*:*</query></delete>')
    IndexEvent.post_to_solr(solr_xml_string)
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

end

