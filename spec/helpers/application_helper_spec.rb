# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "facet_links_for_category_and_subject" do
    let(:request) { double }

    before do
      allow(helper).to receive(:request).and_return(request)
      allow(request).to receive(:protocol).and_return('http://')
      allow(request).to receive(:host_with_port).and_return('test.host')
    end

    context "when category and subject are the same" do
      let(:hash) { { category: 'Totoro', subject: 'Totoro' } }
      it "only gives category link" do
        expect(facet_links_for_category_and_subject(hash)).to eq "<a href=\"http://test.host/catalog?f%5Bcategory_facet%5D%5B%5D=Totoro\">Totoro</a>"
      end
    end
    context "when category and subject are different" do
      let(:hash) { { category: 'Neighbors', subject: 'Totoro' } }
      it "gives both links" do
        expect(facet_links_for_category_and_subject(hash)).to eq \
          "<a href=\"http://test.host/catalog?f%5Bcategory_facet%5D%5B%5D=Neighbors\">Neighbors</a> -- <a href=\"http://test.host/catalog?f%5Bsubject_label_facet%5D%5B%5D=Totoro\">Totoro</a>"
      end
    end
    context "when category is blank" do
      let(:hash) { { category: '', subject: 'Totoro' } }
      it "only gives subject link" do
        expect(facet_links_for_category_and_subject(hash)).to eq "<a href=\"http://test.host/catalog?f%5Bsubject_label_facet%5D%5B%5D=Totoro\">Totoro</a>"
      end
    end
  end

  describe "#available_translations" do
    it "returns a hash of strings" do
      expect(helper.available_translations['en']).to eq 'English'
    end
  end

  describe "#locale_switch_link" do
    let(:request) { double }

    before do
      allow(helper).to receive(:request).and_return(request)
      allow(request).to receive(:original_fullpath).and_return(original_fullpath)
      allow(helper).to receive(:params).and_return(params)
      allow(request).to receive(:query_parameters).and_return(query_params)
    end

    context "on root path" do
      let(:original_fullpath) { "/" }
      let(:params) do
        ActionController::Parameters.new("id" => "index", "controller" => "pages", "action" => "show")
      end
      let(:query_params) { {} }
      it "adds a locale where there were no params" do
        expect(helper.locale_switch_link("es")).to eq "/?locale=es"
      end
    end

    context "on search path" do
      let(:original_fullpath) { "/catalog?utf8=%E2%9C%93&search_field=all_fields&q=health" }
      let(:params) do
        ActionController::Parameters.new("utf8" => "✓", "search_field" => "all_fields", "q" => "health", "controller" => "catalog", "action" => "index")
      end
      let(:query_params) do
        { "utf8" => "✓", "search_field" => "all_fields", "q" => "health" }
      end
      it "preserves all the other params" do
        expect(helper.locale_switch_link("es")).to eq "/catalog?utf8=%E2%9C%93&search_field=all_fields&q=health&locale=es"
      end
    end

    context "on search_history path" do
      let(:original_fullpath) { "/search_history?locale=pt-BR" }
      let(:params) do
        ActionController::Parameters.new("locale" => "pt-BR", "controller" => "search_history", "action" => "index")
      end
      let(:query_params) { { "locale" => "pt-BR" } }
      before do
        allow(I18n).to receive(:locale).and_return(:"pt-BR")
      end
      it "substitutes locale from existing locale param" do
        expect(helper.locale_switch_link("es")).to eq "/search_history?locale=es"
      end
    end
  end

  describe "#viewer_data_uri" do
    it "doesn't include the locale" do
      expect(helper.viewer_data_uri("/catalog/07gmd?locale=en")).to eq "/catalog/07gmd.jsonld"
    end
  end

  describe "#link_with_locale" do
    let(:params) do
      ActionController::Parameters.new("locale" => "pt-BR")
    end
    before do
      allow(helper).to receive(:params).and_return(params)
      allow(I18n).to receive(:locale).and_return(:"pt-BR")
    end
    it "adds current locale to a link" do
      expect(helper.link_with_locale("/catalog/07gmd")).to eq "/catalog/07gmd?locale=pt-BR"
    end
  end
end
