require 'spec_helper'
require 'cma/oft/current/case'
require 'nokogiri'

module CMA::OFT::Current
  describe Case do
    When(:_case) { Case.create('http://example.com/1', 'title') }

    Then { _case.title        == 'title' }
    Then { _case.original_url == 'http://example.com/1' }

    describe '.add_summary' do
      Given(:summary) do
        Nokogiri::HTML(File.read("spec/fixtures/oft/#{filename}"))
      end
      When { _case.add_summary(summary) }

      context 'A normal summary' do
        Given(:filename) { 'market-studies-2002-taxi-services.html' }

        Then { expect(_case.summary).to include('The purpose of the study') }
      end

      context 'A summary with its text in an ol rather than a p' do
        Given(:filename) { 'baa-airports-odd-summary.html' }

        Then { expect(_case.summary).to include('1.  To examine the scope') }
      end

      context 'Sports goods - no content, just nav found' do
        Given(:filename) { 'sports-goods.html' }

        Then { expect(_case.summary).to include('In September 2009, following the receipt of information') }
        And  { expect(_case.summary).not_to include('[Back to top<span>') }
      end

      context 'Consumer IT (summary split over elements)' do
        Given(:filename) { 'consumer-it-services.html' }

        Then { expect(_case.summary).to include('The purpose of study')}
        Then { expect(_case.summary).to include('address competition concerns')}
        Then { expect(_case.summary).to include('examine whether there')}
        Then { expect(_case.summary).not_to include('case page')}
      end
    end

    describe '.add_detail' do
      Given(:detail) do
        Nokogiri::HTML(File.read('spec/fixtures/oft/market-studies-2002-taxi-services-case-detail.html'))
      end

      When { _case.add_detail(detail) }

      Invariant { expect(_case.body).not_to include '<p>'}
      Invariant { expect(_case.body).not_to include '&nbsp;'}
      Invariant { expect(_case.body).not_to include '<script'}
      Invariant { expect(_case.body).not_to include '<span>'}
      Invariant { expect(_case.body).not_to include '<div'}
      Invariant { expect(_case.body).not_to include '[Initial'}
      Invariant { expect(_case.body).not_to include 'backtotop'}
      Invariant { expect(_case.body).not_to include('[1]: http://webarchive')}

      Then { expect(_case.body).to include('Purpose of the study') }
      And  { expect(_case.body).not_to include(
        'http://webarchive.nationalarchives.gov.uk/20140402141250/http://oft.gov.uk/shared_oft/reports/comp_policy/oft676annexee.pdf')
      }
      And  { expect(_case.body).to include('http://oft.gov.uk/shared_oft/reports/comp_policy/oft676annexee.pdf') }
      And  { expect(_case.original_urls).to include 'http://www.oft.gov.uk/OFTwork/markets-work/taxis' }

    end
  end
end
