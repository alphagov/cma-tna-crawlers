require 'spec_helper'
require 'cma/oft/crawler'

module CMA::OFT
  describe Crawler do
    describe 'a case list' do
      it 'matches the daft interstitial page when no query string' do
        expect(Crawler::CASE_LIST_INTERSTITIAL).to match(
          'http://webarchive.nationalarchives.gov.uk/20140402163422/'\
          'http://www.oft.gov.uk/OFTwork/oft-current-cases/market-studies-2005/')
      end
      it 'matches case list for year when query string is there' do
        expect(Crawler::CASE_LIST_FOR_YEAR).to match(
          'http://webarchive.nationalarchives.gov.uk/20140402163422/'\
          'http://www.oft.gov.uk/OFTwork/oft-current-cases/consumer-case-list-2009/?Order=Date&currentLetter=A')
      end
      it 'matches case list for year when query string is there' do
        expect(Crawler::CASE_LIST_FOR_YEAR).not_to match(
          'http://webarchive.nationalarchives.gov.uk/20140402163422/'\
          'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2011/electronic-platform-services')
      end

      describe 'Crawler::CASE_DETAIL' do
        it 'knows about markets work' do
          expect(Crawler::CASE_DETAIL).to match(
            'http://webarchive.nationalarchives.gov.uk/20140402163422/'\
            'http://www.oft.gov.uk/OFTwork/markets-work/QandAs')
        end
        it 'knows about consumer enforcement cases' do
          expect(Crawler::CASE_DETAIL).to match(
            'http://webarchive.nationalarchives.gov.uk/20140402163422/'\
            'http://www.oft.gov.uk/OFTwork/consumer-enforcement/consumer-enforcement-completed/ama-vitalbeauty/')
        end
        it 'knows about market studies cases' do
          expect(Crawler::CASE_DETAIL).to match(
            'http://webarchive.nationalarchives.gov.uk/20140402163422/'\
            'http://www.oft.gov.uk/OFTwork/oft-current-cases/market-studies-2005/PPRS')
        end
      end
    end

  end
end