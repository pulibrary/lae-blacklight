# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Search History', type: :feature do
  scenario 'my recent searches should be displayed in the search history' do
    visit '/catalog?q=test&search_field=all_fields'
    visit '/search_history'
    expect(page).to have_selector 'span.filter-values', text: 'test'
  end
end
