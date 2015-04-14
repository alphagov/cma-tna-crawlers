require 'spec_helper'
require 'cma/crawler/base'

module CMA::Crawler
  describe '#hrefs_for' do
    # Base is an abstract class that's inherited by all the concrete Crawler
    # classes around the project.
    # Its #hrefs_for method makes use of a #link_nodes_for method that's only
    # defined on subclasses of Base, not on Base itself.
    # Therefore, to test #hrefs_for, we're defining a subclass of Base to
    # perform the actual test on.
    class ConcreteCrawler < Base; end
    let(:crawler) { ConcreteCrawler.new }
    let(:link_nodes) { [{'href' => 'abc'}, {'href' => nil}, {'href' => 'ghi'}] }
    let(:non_nil_hrefs) { ['abc', 'ghi'] }
    let(:page) { double }

    it 'returns all non-nil hrefs from link nodes' do
      allow(crawler).to receive(:link_nodes_for) { link_nodes }

      expect(crawler.hrefs_for(page)).to eq(non_nil_hrefs)
    end
  end
end
