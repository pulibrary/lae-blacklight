# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BookmarksController, type: :request do
  describe 'viewing bookmarks' do
    it 'displays the bookmarks' do
      put '/bookmarks/004kr', params: { id: '004kr' }

      get '/bookmarks'
      expect(response.status).to eq 200
    end
  end
end
