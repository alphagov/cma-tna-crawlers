require 'spec_helper'
require 'cma/oft/case'
require 'nokogiri'

module CMA::OFT
  describe Case do
    Given(:_case) { Case.create('http://example.com/1', 'title') }

    Then { _case.title        == 'title' }
    Then { _case.original_url == 'http://example.com/1' }

    describe '.add_summary' do
      Given(:summary) do
        Nokogiri::HTML(File.read('spec/fixtures/oft/market-studies-2002-taxi-services.html'))
      end

      When { _case.add_summary(summary) }

      Then { expect(_case.summary).to include('The purpose of the study') }
    end
  end
end
