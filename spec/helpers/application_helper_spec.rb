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
end
