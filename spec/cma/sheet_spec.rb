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

      And  { row.market_sector == 'Recreation and Leisure' }
      And  { row.opened_date   == Date.new(2013, 6, 1) }
      And  { row.closed_date   == Date.new(2014, 1, 1) }
      And  { row.outcome_type  == 'consumer-enforcement-undertakings' }

      And  {
        row.link.original_url ==
          'http://www.oft.gov.uk'\
          '/OFTwork/consumer-enforcement/consumer-enforcement-completed/air-travel/'
      }

      it 'parses all outcome_types' do
        sheet.rows.each {|row| expect(row.outcome_type).to be_a(String)}
      end
    end
  end

  context 'markets work' do
    Given(:filename) { 'sheets/markets-work.csv' }

    Then { sheet.rows.size == 10 }

    describe 'the first row' do
      Given(:row) { sheet.rows[0] }

      Then { expect(row).to be_a(CMA::Sheet::Row) }

      And  { row.market_sector == 'Transport' }
      And  { row.opened_date   == Date.new(2006, 12, 1) }
      And  { row.closed_date   == Date.new(2007, 3, 30) }
      And  { row.outcome_type  == 'markets-phase-1-referral' }

      And  {
        row.link.original_url ==
          'http://www.oft.gov.uk/OFTwork/markets-work/references/airports'
      }

      it 'parses all dates' do
        sheet.rows.each do |row|
          expect(row.opened_date).to satisfy {|date| date.nil? || date.is_a?(Date)}
        end
      end
    end
  end


  describe '.all' do
    Given(:sheet_files) { Dir['sheets/*.csv'] }

    it 'has all sheets' do
      expect(CMA::Sheet.all.map(&:filename)).to \
        match_array(sheet_files)
    end
  end
end
