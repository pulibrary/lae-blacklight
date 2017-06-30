# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PagesController, type: :request do
  describe "get /about" do
    it 'successfully renders the \'about\' template' do
      get '/about'
      expect(response.status).to eq 200
      expect(response).to render_template('about')
    end
  end

  describe 'get /' do
    it 'successfully renders the index template' do
      get '/'
      expect(response.status).to eq 200
      expect(response).to render_template('index')
    end
  end
end
