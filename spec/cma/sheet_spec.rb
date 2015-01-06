require 'spec_helper'
require 'cma/sheet'

describe CMA::Sheet do
  Given(:sheet) { CMA::Sheet.new(filename) }

  context 'consumer enforcement' do
    Given(:filename) { 'sheets/consumer-enforcement.csv' }

    Then { sheet.rows.size == 49 }

    describe 'the first row' do
      Given(:row) { sheet.rows[0] }

      Then { expect(row).to be_a(CMA::Sheet::Row) }

      Then { row.market_sector == 'Recreation and Leisure' }
      Then { row.open_date     == Date.new(2013, 6, 1) }
      Then { row.decision_date == Date.new(2014, 1, 1) }

      Then {
        row.link.original_url ==
          'http://www.oft.gov.uk'\
          '/OFTwork/consumer-enforcement/consumer-enforcement-completed/air-travel/'
      }
    end
  end


end
