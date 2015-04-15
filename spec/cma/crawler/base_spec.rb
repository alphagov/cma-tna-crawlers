require 'spec_helper'
require 'cma/crawler/base'

module CMA::Crawler
  context 'as subclassed concrete crawler' do
    # Base is an abstract class that's inherited by all the concrete Crawler
    # classes around the project.
    # Some of its methods make use of other methods that're only defined on
    # subclasses of Base, not on Base itself.
    # Therefore, to test these methods, we're defining a subclass of Base to
    # perform these tests on.
    class ConcreteCrawler < Base; end
    let(:crawler) { ConcreteCrawler.new }

    describe '#hrefs_for' do
      let(:link_nodes) { [{'href' => 'abc'}, {'href' => nil}, {'href' => 'ghi'}] }
      let(:non_nil_hrefs) { ['abc', 'ghi'] }
      let(:page) { double }

      it 'returns all non-nil hrefs from link nodes' do
        allow(crawler).to receive(:link_nodes_for) { link_nodes }

        expect(crawler.hrefs_for(page)).to eq(non_nil_hrefs)
      end
    end

    describe '#clean_hrefs_for' do
      let(:hrefs) {
        [
          'http://example.com/virgin_fares.pdf',
          'http://example.com/Parties_and_fines.pdf;jsessionid=2384293487',
        ]
      }
      let(:clean_hrefs) {
        [
          'http://example.com/virgin_fares.pdf',
          'http://example.com/Parties_and_fines.pdf',
        ]
      }
      let(:page) { double }

      it 'returns all non-nil hrefs from link nodes' do
        allow(crawler).to receive(:hrefs_for) { hrefs }

        expect(crawler.clean_hrefs_for(page)).to eq(clean_hrefs)
      end
    end
  end
end
