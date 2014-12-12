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
          JSON.parse(first.to_json) == {
            'title' => 'Investigation into the supply of healthcare products',
            'original_url' =>
              'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2013/healthcare-products',
            'case_state' => 'closed',
            'case_type' => 'unknown'
          }
        end

        describe '#save_to' do
          let(:case_store) { instance_spy CMA::CaseStore }

          it 'saves all the cases to the case store' do
            list.save_to(case_store)

            list.cases.each do |_case|
              expect(case_store).to have_received(:save).with(_case)
            end
          end
        end
      end
    end
  end
end
