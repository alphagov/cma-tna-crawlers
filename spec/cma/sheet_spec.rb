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
      Then { row.outcome       == 'consumer-enforcement-undertakings' }

      Then {
        row.link.original_url ==
          'http://www.oft.gov.uk'\
          '/OFTwork/consumer-enforcement/consumer-enforcement-completed/air-travel/'
      }

      it 'parses all outcomes' do
        sheet.rows.each {|row| expect(row.outcome).to be_a(String)}
      end
    end
  end

  context 'markets work' do
    Given(:filename) { 'sheets/markets-work.csv' }

    Then { sheet.rows.size == 14 }

    describe 'the first row' do
      Given(:row) { sheet.rows[0] }

      Then { expect(row).to be_a(CMA::Sheet::Row) }

      Then { row.market_sector == 'Building and construction' }
      Then { row.open_date     == Date.new(2011, 8, 1) }
      Then { row.decision_date == Date.new(2021, 1, 18) }
      Then { row.outcome       == 'markets-phase-1-referral' }

      Then {
        row.link.original_url ==
          'http://www.oft.gov.uk/OFTwork/markets-work/references/aggregates-MIR'
      }

      it 'parses all dates' do
        sheet.rows.each do |row|
          expect(row.open_date).to satisfy {|date| date.nil? || date.is_a?(Date)}
        end
      end
    end
  end


end
