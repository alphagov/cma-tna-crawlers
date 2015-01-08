require 'spec_helper'
require 'cma/oft/mergers_crawler'

module CMA::OFT
  describe MergersCrawler do
    describe 'a case list' do
      context '2002-2009' do
        it 'matches case list for year' do
          expect(MergersCrawler::CASE_LIST).to match(
            '/OFTwork/mergers/Mergers_Cases/2004/?Order=Date&currentLetter=A')
        end
        it 'matches cases' do
          expect(MergersCrawler::CASE).to match(
            '/OFTwork/mergers/Mergers_Cases/2004/firstgroup2')
        end
        it 'matches the old-style subpages that look like decisions'\
           'and captures to $1' do
          MergersCrawler::SUBPAGE.match \
            '/OFTwork/mergers/decisions/2004/firstgroupscot'
          expect($1).to eql('decisions/2004/firstgroupscot')
        end
      end

      context '2010-2014' do
        it 'matches case list for year' do
          expect(MergersCrawler::CASE_LIST).to match(
            'http://www.oft.gov.uk/OFTwork/mergers/decisions/2012/')
        end
        it 'matches cases' do
          abellio = '/OFTwork/mergers/decisions/2012/abellio'
          expect(MergersCrawler::CASE_LIST).not_to match(abellio)
          expect(MergersCrawler::CASE).to match(abellio)
        end
      end
    end
  end
end
