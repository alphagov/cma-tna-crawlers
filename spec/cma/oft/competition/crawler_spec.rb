require 'spec_helper'
require 'cma/oft/competition/crawler'

module CMA::OFT::Competition
  describe 'Case detail' do
    it 'matches Reckitt Benckiser (cases at /decisions/)' do
      expect(Crawler::CASE_DETAIL).to match(
        'http://oft.gov.uk/OFTwork/competition-act-and-cartels/ca98/decisions/reckitt-benckiser')
    end
  end

  describe '#link_nodes_for' do
    let(:crawler) { Crawler.new }
    let(:main_page_link_nodes) { 3 }
    let(:sidebar_link_nodes) { 2 }

    context 'with a non-CASE_DETAIL page' do
      let(:page) {
        Anemone::Page.new(
          'http://www.oft.gov.uk/OFTwork/competition-act-and-cartels/ca98/',
          :body => File.read('spec/fixtures/oft/decisions-aberdeen-journals2.html'),
          :headers => {'content-type' => ['text/html']},
        )
      }

      it 'should scrape main page link nodes only' do
        expect(crawler.link_nodes_for(page).size).to eq(main_page_link_nodes)
      end
    end

    context 'with a CASE_DETAIL page' do
      let(:page) {
        Anemone::Page.new(
          'http://www.oft.gov.uk/OFTwork/competition-act-and-cartels/ca98/decisions/aberdeen-journals2',
          :body => File.read('spec/fixtures/oft/decisions-aberdeen-journals2.html'),
          :headers => {'content-type' => ['text/html']},
        )
      }

      it 'should scrape both main page and sidebar link nodes' do
        expect(crawler.link_nodes_for(page).size).to eq(main_page_link_nodes + sidebar_link_nodes)
      end
    end
  end
end
