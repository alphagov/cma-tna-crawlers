require 'spec_helper'
require 'cma/oft/mergers/crawler'

module CMA::OFT::Mergers
  describe Crawler do
    describe 'a case list' do
      context '2002-2009' do
        it 'matches case list for year' do
          expect(Crawler::CASE_LIST).to match(
            '/OFTwork/mergers/Mergers_Cases/2004/?Order=Date&currentLetter=A')
        end
        it 'matches cases' do
          expect(Crawler::CASE).to match(
            '/OFTwork/mergers/Mergers_Cases/2004/firstgroup2')
        end
        it 'matches the old-style subpages that look like decisions'\
           'and captures to $1' do
          Crawler::SUBPAGE.match \
            '/OFTwork/mergers/decisions/2004/firstgroupscot'
          expect($1).to eql('decisions/2004/firstgroupscot')
        end
      end

      context '2010-2014' do
        it 'matches case list for year' do
          expect(Crawler::CASE_LIST).to match('/OFTwork/mergers/decisions/2012/')
          expect(Crawler::CASE_LIST).to match('/OFTwork/mergers/decisions/2012')
        end
        it 'matches cases' do
          abellio = '/OFTwork/mergers/decisions/2012/abellio'
          expect(Crawler::CASE_LIST).not_to match(abellio)
          expect(Crawler::CASE).to match(abellio)
        end
      end

      context '2010 decisions that are not new-style case subpages'\
              '(rather just late decisions on 2009 cases)' do
        shared_examples 'it is not a case, it is a subpage' do
          it 'is not a case' do
            expect(Crawler::CASE).not_to match(path)
          end
          it 'is a subpage' do
            expect(Crawler::SUBPAGE).to match(path)
          end
        end

        context 'lse' do
          let(:path) { '/OFTwork/mergers/decisions/2010/london-stock-exchange' }

          it_behaves_like 'it is not a case, it is a subpage'
        end

        context 'gne' do
          let(:path) { '/OFTwork/mergers/decisions/2010/go-north-east' }

          it_behaves_like 'it is not a case, it is a subpage'
        end

        context 'Arriva' do
          let(:path) { '/OFTwork/mergers/decisions/2010/arriva' }

          it_behaves_like 'it is not a case, it is a subpage'
        end

        context 'Koppers' do
          let(:path) { '/OFTwork/mergers/decisions/2010/Koppers' }

          it_behaves_like 'it is not a case, it is a subpage'
        end
      end
    end
  end
end
