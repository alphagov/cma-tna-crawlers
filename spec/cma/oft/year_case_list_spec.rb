require 'spec_helper'
require 'cma/oft/year_case_list'
require 'cma/case_store'
require 'nokogiri'

module CMA::OFT
  describe YearCaseList do
    describe '.new' do
      When(:list) do
        YearCaseList.new(
          Nokogiri::HTML(File.read("spec/fixtures/oft/#{filename}")))
      end

      let(:first_case_hash) {
        {
          'title' => 'Investigation into the supply of healthcare products',
          'original_url' =>
            'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2013/healthcare-products',
          'original_urls' => [
            'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2013/healthcare-products'
          ],
          'case_state' => 'closed',
          'case_type' => 'unknown'
        }
      }

      context 'Competition case list 2011 (has case not on by date page)' do
        Given(:filename) { 'competition-case-list-2011.html' }

        describe 'adding a virtual case "Access control and alarm systems case" to the list' do
          it 'adds one to the list' do
            expect(list.cases.size).to eql(7)
          end

          When (:_case) { list.cases.last }

          Then { _case.title        == 'Access control and alarm systems case' }
          Then { _case.original_url == 'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2011/access-control-alarm-systems' }
        end
      end

      context 'Competition case list 2013' do
        Given(:filename) { 'competition-case-list-2013.html' }

        Then { list.cases.size == 3 }

        Given(:first) { list.cases.first }
        Given(:last)  { list.cases.last }

        Then { first.title        == 'Investigation into the supply of healthcare products' }
        Then { first.original_url == 'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2013/healthcare-products' }
        Then { last.title         == 'Provision of training services to the construction industry' }
        Then { last.original_url  == 'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2013/training-construction-industry' }

        Then do
          JSON.parse(first.to_json) == first_case_hash
        end

        describe '#save_to' do
          let(:case_store) { instance_spy CMA::CaseStore }

          context 'no params are given' do
            it 'saves all the cases to the case store' do
              list.save_to(case_store)

              list.cases.each do |_case|
                expect(case_store).to have_received(:save).with(_case)
              end
            end
          end

          context 'cases exist and noclobber is true' do
            Given(:first_case) { list.cases.first }
            before do
              expect(case_store).to receive(:exists?).with(
                first_case_hash['original_url']).and_return(true)
            end

            it 'does not replace cases that already exist' do
              list.save_to(case_store, noclobber: true)

              expect(case_store).not_to have_received(:save).with(first_case)
            end
          end
        end
      end

      context 'Mergers case lists' do
        context '2003 case list (representative of 2002-2009 type)' do
          Given(:filename) { 'mergers-case-list-2003.html' }

          When(:_case) { list.cases.first }

          Then { list.cases.size == 63 }

          Then { _case.title        == 'Carl Zeiss / Bio-Rad' }
          Then { _case.original_url == 'http://www.oft.gov.uk/OFTwork/mergers/Mergers_Cases/2003/CarlZeiss' }
        end

        context '2010 case list (representative of 2010-2014 type)' do
          Given(:filename) { 'mergers-case-list-2010.html' }

          Then { list.cases.size == 70 }

          it 'does not recognise subpages as cases, as this would leave'\
             'cases that are not cases in the case store' do
            require 'cma/oft/mergers/case'

            list.cases.map(&:original_url).each do |original_url|
              expect(original_url).not_to match(Mergers::Case::SUBPAGE_NOT_CASE)
            end
          end

          describe 'the first case' do
            When(:_case) { list.cases.first }

            Then { _case.title        == '2 Sisters' }
            Then { _case.original_url == 'http://www.oft.gov.uk/OFTwork/mergers/decisions/2010/2-sisters' }
          end
        end
      end
    end
  end
end
