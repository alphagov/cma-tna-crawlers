require 'spec_helper'
require 'cma/case_store/augment_from_sheet'

describe CMA::CaseStore::AugmentFromSheet do
  let(:case_store) { CMA::CaseStore.new('spec/fixtures/store') }

  before do
    FileUtils.rmtree(case_store.location)
    FileUtils.cp_r('spec/fixtures/augmentable_case_store', case_store.location)
  end
  after  { FileUtils.rmtree(case_store.location) }

  context 'augmenting cases' do
    let(:error_only_logger) do
      # Logger.new(File.open('/dev/null', File::WRONLY))
      Logger.new(STDOUT).tap do |logger|
        logger.level = Logger::ERROR
      end
    end

    Given(:augment) do
      CMA::CaseStore::AugmentFromSheet.new(
        case_store, CMA::Sheet.new(filename), error_only_logger)
    end

    Given { augment.run! }

    context 'augmenting consumer cases' do
      Given(:filename) { 'sheets/consumer-enforcement.csv' }

      Then { augment.case_store == case_store }
      And  { augment.sheet.filename == filename }

      describe 'the results' do
        Given(:filename) { 'sheets/consumer-enforcement.csv' }

        When(:loaded_case) do
          case_store.find(
            'http://www.oft.gov.uk/OFTwork/oft-current-cases/consumer-case-list-2012/acorn')
        end

        Then { loaded_case.outcome_type  == 'consumer-enforcement-no-action' }
        Then { loaded_case.market_sector == 'healthcare-and-medical-equipment' }
        Then { loaded_case.title         ==
          'Acorn Mobility Services Ltd: unfair consumer contract terms and conditions'
        }
        Then { loaded_case.opened_date   == '2012-02-01' }
        Then { loaded_case.closed_date   == '2012-02-01' }
        Then { loaded_case.case_type     == 'consumer-enforcement' }

        Then { loaded_case.modified_by_sheet == true}
      end
    end

    context 'augmenting CC cases, which have a case_type' do
      Given(:filename) { 'sheets/cc.csv' }

      When(:loaded_case) do
        case_store.find(
          'http://www.competition-commission.org.uk'\
          '/our-work/directory-of-all-inquiries/bbc-c4-itv-joint-venture'
        )
      end

      Then { loaded_case.case_type == 'mergers' }
    end
  end

end
