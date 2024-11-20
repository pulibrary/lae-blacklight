# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Search', type: :feature do
  feature 'date range' do
    scenario 'limits search results' do
      visit '/catalog?range[date_created_facet][begin]=1990&range[date_created_facet][end]=2018&search_field=all_fields'
      expect(page).to have_selector 'span.from', text: '1990'
      expect(page).to have_selector 'span.to', text: '2018'
      expect(page).to have_content 'Remove constraint Date Created'
      within ".blacklight-date_created_facet" do
        expect(page).to have_button "Apply"
      end
    end
  end
end
