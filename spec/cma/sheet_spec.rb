require 'spec_helper'
require 'cma/sheet'

describe CMA::Sheet do
  Given(:sheet) { CMA::Sheet.new(filename) }

  context 'consumer enforcement' do
    Given(:filename) { 'sheets/consumer-enforcement.csv' }

    Then { sheet.rows.size == 51 }

    describe 'the first row' do
      Given(:row) { sheet.rows[0] }

      Then { expect(row).to be_a(CMA::Sheet::Row) }

      And  { row.market_sector == 'recreation-and-leisure' }
      And  { row.opened_date   == Date.new(2005, 9, 1) }
      And  { row.closed_date   == Date.new(2011, 8, 1) }
      And  { row.outcome_type  == 'consumer-enforcement-court-order' }

      And  {
        row.link.original_url ==
          'http://www.oft.gov.uk'\
          '/OFTwork/consumer-enforcement/consumer-enforcement-completed/ashbourne/'
      }

      it 'parses all outcome_types' do
        sheet.rows.each_with_index do |row, index|
          expect(row.outcome_type).to be_a(String),
            "Row #{index}'s outcome_type was not a string"
        end
      end

      FOXTONS_INDEX = 1
      EHIC_INDEX = 49
      it 'maps odd sectors' do
        expect(sheet.rows[FOXTONS_INDEX].market_sector).to \
          eql('distribution-and-service-industries')
      end
      it 'maps odd sectors' do
        expect(sheet.rows[EHIC_INDEX].market_sector).to \
          eql('distribution-and-service-industries')
      end
    end
  end

  context 'markets work' do
    Given(:filename) { 'sheets/markets-work.csv' }

    Then { sheet.rows.size == 10 }

    describe 'the first row' do
      Given(:row) { sheet.rows[0] }

      Then { expect(row).to be_a(CMA::Sheet::Row) }

      And  { row.market_sector == 'transport' }
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

  context 'CC' do
    Given(:filename) { 'sheets/cc.csv' }

    Then { sheet.rows.size == 131 }

    describe 'the first row' do
      Given(:row) { sheet.rows[0] }

      Then { expect(row).to be_a(CMA::Sheet::Row) }

      And  { row.market_sector == 'transport' }
      And  { row.opened_date   == Date.new(2007, 3, 29) }
      And  { row.closed_date   == Date.new(2009, 3, 19) }
      And  { row.outcome_type  == 'markets-phase-2-adverse-effect-on-competition-leading-to-remedies' }

      And  {
        row.link.original_url ==
          'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/baa-airports'
      }

      it 'parses all dates' do
        sheet.rows.each do |row|
          expect(row.opened_date).to satisfy {|date| date.nil? || date.is_a?(Date)}
        end
      end
    end
  end

  context 'Mergers' do
    context '06-07' do
      Given(:filename) { 'sheets/mergers06-08/Mergers 06-07-Table 1.csv' }

      Then { sheet.rows.size == 261 }

      describe 'the first row' do
        Given(:row) { sheet.rows[0] }

        Then { expect(row).to be_a(CMA::Sheet::Row) }

        Then { row.market_sector == 'transport' }
        Then { row.opened_date   == nil }
        Then { row.closed_date   == Date.new(2007, 11, 28) }
        Then { row.outcome_type  == 'mergers-phase-1-found-not-to-qualify' }

        Then  {
          row.link.original_url ==
            'http://www.oft.gov.uk/OFTwork/mergers/Mergers_Cases/2007/GoNorthEast'
        }

        it 'parses all dates' do
          sheet.rows.each do |row|
            expect(row.opened_date).to satisfy {|date| date.nil? || date.is_a?(Date)}
          end
        end
      end
    end
    context '08' do
      Given(:filename) { 'sheets/mergers06-08/Mergers 08-Table 1.csv' }

      Then { sheet.rows.size == 88 }

      describe 'the first row' do
        Given(:row) { sheet.rows[0] }

        Then { expect(row).to be_a(CMA::Sheet::Row) }

        Then { row.market_sector == 'energy' }
        Then { row.opened_date   == nil }
        Then { row.closed_date   == Date.new(2008, 10, 23) }
        Then { row.outcome_type  == 'mergers-phase-1-found-not-to-qualify' }

        Then  {
          row.link.original_url ==
            'http://www.oft.gov.uk/OFTwork/mergers/Mergers_Cases/2008/Nuclear'
        }

        it 'parses all dates' do
          sheet.rows.each do |row|
            expect(row.opened_date).to satisfy {|date| date.nil? || date.is_a?(Date)}
          end
        end
      end
    end
    context '09' do
      Given(:filename) { 'sheets/mergers09-14/Mergers 09-Table 1.csv' }

      Then { sheet.rows.size == 73 }

      describe 'the first row' do
        Given(:row) { sheet.rows[0] }

        Then { expect(row).to be_a(CMA::Sheet::Row) }

        Then { row.market_sector == 'agriculture-environment-and-natural-resources' }
        Then { row.opened_date   == nil }
        Then { row.closed_date   == Date.new(2009, 4, 17) }
        Then { row.outcome_type  == 'mergers-phase-1-clearance' }

        Then  {
          row.link.original_url ==
            'http://www.oft.gov.uk/OFTwork/mergers/Mergers_Cases/2009/ab-agri'
        }

        it 'parses all dates' do
          sheet.rows.each do |row|
            expect(row.opened_date).to satisfy {|date| date.nil? || date.is_a?(Date)}
          end
        end
      end
    end
    context '10' do
      Given(:filename) { 'sheets/mergers09-14/Mergers 10-11-Table 1.csv' }

      Then { sheet.rows.size == 171 }

      describe 'the first row' do
        Given(:row) { sheet.rows[0] }

        Then { expect(row).to be_a(CMA::Sheet::Row) }

        Then { row.market_sector == 'food-manufacturing' }
        Then { row.opened_date   == nil }
        Then { row.closed_date   == Date.new(2010, 6, 28) }
        Then { row.outcome_type  == 'mergers-phase-1-clearance' }

        Then  {
          row.link.original_url ==
            'http://www.oft.gov.uk/OFTwork/mergers/decisions/2010/2-sisters'
        }

        it 'parses all dates' do
          sheet.rows.each do |row|
            expect(row.opened_date).to satisfy {|date| date.nil? || date.is_a?(Date)}
          end
        end
      end
    end
  end

  describe '.all' do
    Given(:sheet_files) { Dir['sheets/**/*.csv'] }

    it 'has all sheets' do
      expect(CMA::Sheet.all.map(&:filename)).to \
        match_array(sheet_files)
    end
  end

  describe '.parse_date' do
    When(:result) { CMA::Sheet::Row.parse_date(date_str) }

    context 'nil' do
      Given(:date_str) { nil }

      Then { result == nil }
    end

    context 'normal slashed dates' do
      Given(:date_str) { '17/02/04' }

      Then { result == Date.new(2004, 02, 17) }
    end

    context 'CC dotted dates' do
      Given(:date_str) { '17.02.04' }

      Then { result == Date.new(2004, 02, 17) }
    end

    context 'American slashed dates (no zero)' do
      Given(:date_str) { '2/17/04' }

      Then { result == Date.new(2004, 02, 17) }
    end

    context 'year-only' do
      Given(:date_str) { '2010' }

      Then { result == nil }
    end

    context 'bad input' do
      Given(:date_str) { '1702.04' }

      Then { result == Failure(ArgumentError, /invalid date/) }
    end
  end
end
