require 'spec_helper'
require 'cma/case_store/augment_from_sheet'

describe CMA::CaseStore::AugmentFromSheet do
  let(:case_store) { CMA::CaseStore.new('spec/fixtures/store') }

  before do
    FileUtils.rmtree(case_store.location)
    FileUtils.cp_r('spec/fixtures/augmentable_case_store', case_store.location)
  end
  after  { FileUtils.rmtree(case_store.location) }

  context 'augmenting consumer cases' do
    let(:null_logger) do
      Logger.new(File.open('/dev/null', File::WRONLY))
    end

    Given(:augment) do
      CMA::CaseStore::AugmentFromSheet.new(
        case_store, CMA::Sheet.new('sheets/consumer-enforcement.csv'), null_logger)
    end

    Then { augment.case_store == case_store }
    And  { augment.sheet.filename == 'sheets/consumer-enforcement.csv' }

    describe 'the results' do
      Given { augment.run! }

      When(:loaded_case) do
        case_store.find(
          'http://www.oft.gov.uk/OFTwork/oft-current-cases/consumer-case-list-2012/acorn')
      end

      Then { loaded_case.outcome_type  == 'consumer-enforcement-undertakings' }
      Then { loaded_case.market_sector == 'healthcare-and-medical-equipment' }
      Then { loaded_case.title         ==
        'Acorn Mobility Services Ltd: consumer terms and conditions'
      }
      Then { loaded_case.opened_date   == '2012-02-01' }
      Then { loaded_case.closed_date   == '2012-02-01' }

      Then { loaded_case.modified_by_sheet == true}
    end
  end

end
