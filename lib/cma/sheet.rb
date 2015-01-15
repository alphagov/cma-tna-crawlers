require 'csv'
require 'cma/link'
require 'cma/schema'

module Enumerable
  ##
  # Return first truthy result as returned by the given block for an enumerable
  def find_yield(fallback=nil)
    each do |item|
      result = yield(item)
      return result if result
    end
    fallback
  end
end

module CMA
  class Sheet
    attr_accessor :filename

    def initialize(filename)
      self.filename = filename
    end

    class Row
      SLASHED_DATE_FORMAT       = '%d/%m/%y'
      DOTTED_DATE_FORMAT        = '%d.%m.%y'
      DASHED_THREE_LETTER_MONTH = '%d-%b-%y'
      AMERICAN_NO_LEAD_ZERO     = '%m/%d/%y' # Yes, really
      YEAR_ONLY                 = /20[0-9]{2}/

      POSSIBLE_DATE_FORMATS = [
        SLASHED_DATE_FORMAT,
        DOTTED_DATE_FORMAT,
        DASHED_THREE_LETTER_MONTH,
        AMERICAN_NO_LEAD_ZERO
      ]

      OUTCOME_MAPPINGS = {
        'Undertakings'               => 'consumer-enforcement-undertakings',
        'Court order'                => 'consumer-enforcement-court-order',
        'No action'                  => 'consumer-enforcement-no-action',
        'markets - phase 1 referral' => 'markets-phase-1-referral',
        'Regulatory appeals and references - final determination' =>
          'regulatory-references-and-appeals-final-determination',
        '?' => 'UNKNOWN'
      }

      def initialize(row)
        @row = row
      end

      def title
        @row['Title'] || @row['Title ']
      end

      def market_sector
        @row['Market sector'] || @row['New CMA market sector']
      end

      def ref
        @row['Ref']
      end

      def raw
        @row
      end

      def outcome_type
        outcome_title = @row['Outcome'] || @row['Outcome type']
        OUTCOME_MAPPINGS[outcome_title] ||
          CMA::Schema.instance.outcome_types[outcome_title]
      end

      def opened_date
        date_str = @row['Open date'] || @row['Opened date']
        @_open_date ||= Row.parse_date(date_str)
      end

      def closed_date
        @_decision_date ||= Row.parse_date(@row['Closed date'])
      end

      def link
        @_link ||= CMA::Link.new(@row['Archive URL'])
      end

      def self.parse_date(date_str)
        return nil if date_str.nil?

        POSSIBLE_DATE_FORMATS.find_yield do |format|
          begin
            Date.strptime(date_str, format)
          rescue ArgumentError
            nil
          end
        end.tap do |result|
          raise ArgumentError, 'invalid date' if result.nil? && date_str !~ YEAR_ONLY
        end
      end

      def to_s
        @row.to_s
      end
    end

    def rows
      @_rows ||= [].tap do |rows|
        CSV.foreach(filename, headers: true) do |row|
          rows << Row.new(row)
        end
      end
    end

    def self.all
      @_all_sheets = begin
        Dir['sheets/**/*.csv'].map do |filename|
          Sheet.new(filename)
        end
      end.tap do |sheets|
        raise Errno::ENOENT, "No sheets found at #{Dir.pwd}" if sheets.none?
      end
    end
  end
end
