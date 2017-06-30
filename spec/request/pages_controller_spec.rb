require 'rails_helper'

RSpec.describe PagesController, type: :request do
  describe "get /about" do
    subject { get('/about') }
    it 'should respond with 200' do
      expect(subject).to be(200)
    end
    it 'should render the \'about\' template' do
      expect(subject).to render_template('about')
    end
  end

  describe 'get /' do
    subject { get('/') }
    it 'should respond with 200' do
      expect(subject).to be(200)
    end
    it 'should render the index template' do
      expect(subject).to render_template('index')
    end
  end
end
