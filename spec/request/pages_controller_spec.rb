require 'rails_helper'

RSpec.describe PagesController, type: :request do

  %w(about contact).each do |page|

    describe "should get to /#{page}" do
      subject { get(page) }
      it 'should respond with 200' do
        expect(subject).to be(200)
      end
      it 'should render the expected template' do
        expect(subject).to render_template(page)
      end
    end

  end

  describe 'get /' do
    subject { get('/') }
    it 'should respond with 200' do
      expect(subject).to be(200)
    end
    it 'should render the expected template' do
      expect(subject).to render_template('index')
    end
  end

end

