# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def index
      render plain: 'i am an action'
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end

  describe "#default_url_options" do
    it "adds locale param to urls" do
      expect(controller.default_url_options[:locale]).to eq :en
    end
  end

  describe "language setting" do
    it "uses parameter" do
      allow(I18n).to receive(:locale=)
      get :index, params: { locale: 'es' }
      expect(I18n).to have_received(:locale=).with('es')
    end

    it "uses accept_language header if no parameter" do
      allow(I18n).to receive(:locale=)
      allow(controller.request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => "pt-BR")
      get :index
      expect(I18n).to have_received(:locale=).with("pt-BR")
    end

    it "uses pt-BR if pt is given in header" do
      allow(I18n).to receive(:locale=)
      allow(controller.request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => "pt")
      get :index
      expect(I18n).to have_received(:locale=).with("pt-BR")
    end

    it "falls back to default_locale" do
      allow(I18n).to receive(:locale=)
      get :index
      expect(I18n).to have_received(:locale=).with(:en)
    end
  end
end
