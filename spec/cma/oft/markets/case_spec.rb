require 'spec_helper'
require 'cma/oft/markets/case'
require 'nokogiri'

module CMA::OFT::Markets
  describe Case do
    Given(:_case) { Case.create('http://example.com/1', 'title') }

    describe '#section_name' do
      context 'a core page' do
        Given(:url) { 'http://www.oft.gov.uk/OFTwork/markets-work/references/airports' }
        Then { _case.section_name(url) == 'core-documents' }
      end

      context 'a detail page' do
        Given(:url) { 'http://www.oft.gov.uk/OFTwork/markets-work/airports' }
        Then { _case.section_name(url) == 'detail' }
      end

      context 'an extra detail page' do
        Given(:url) { 'http://www.oft.gov.uk/OFTwork/markets-work/references/classified-terms'}
        Then { _case.section_name(url) == 'extra-detail' }
      end

      context 'a same-named section exists' do
        Given(:url) { 'http://www.oft.gov.uk/OFTwork/markets-work/references/varied'}
        Given       { _case.markup_sections['extra-detail'] = 'exists' }

        Then { _case.section_name(url) == 'extra-detail2' }
      end
    end

    describe '#add_subpage' do

      When { _case.add_subpage(doc) }

      context 'BAA main page' do
        let(:doc) do
          Nokogiri::HTML(File.read('spec/fixtures/oft/market-references-baa.html'))
        end

        Then {
          expect(_case.original_urls).to include(
            'http://www.oft.gov.uk/OFTwork/markets-work/references/airports')
        }

        describe 'the core markdown section' do
          subject(:section) do
            _case.markup_sections['core-documents']
          end

          it { should include('BAA airports') }
          it { should include(
                        'The OFT has referred the supply of airport services')
          }
          it { should_not include('<div') }
        end
      end

      context 'BAA detail page' do
        let(:doc) do
          Nokogiri::HTML(File.read('spec/fixtures/oft/markets-work-airports.html'))
        end

        Then {
          expect(_case.original_urls).to include(
            'http://www.oft.gov.uk/OFTwork/markets-work/airports')
        }

        describe 'the detail markdown section' do
          subject(:section) do
            _case.markup_sections['detail']
          end

          it { should include('Purpose of the study') }
          it { should include(
            'To examine the scope for benefits to arise from enhanced competition')
          }
          it { should_not include('<div') }
        end
      end
    end
  end
end
