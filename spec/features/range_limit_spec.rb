# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Search', type: :feature do
  feature 'date range' do
    scenario 'limits search results' do
      visit '/catalog?range[date_created_facet][begin]=1990&range[date_created_facet][end]=1992&search_field=all_fields'
      expect(page).to have_selector 'span.from', text: '1990'
      expect(page).to have_selector 'span.to', text: '1992'
      expect(page).to have_content 'Remove constraint Date Created'
    end
  end
end
