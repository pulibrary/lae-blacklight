# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Search', type: :feature do
  feature 'date range' do
    scenario 'limits search results' do
      visit '/catalog'
      fill_in 'range_date_created_facet_begin', with: '1990'
      fill_in 'range_date_created_facet_end', with: '1992'
      click_button 'Limit'
      expect(page).to have_content 'Remove constraint Date Created'
    end
  end
end
