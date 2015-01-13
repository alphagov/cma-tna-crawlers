require 'csv'
require 'cma/link'

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
      SLASHED_DATE_FORMAT = '%d/%m/%y'
      DOTTED_DATE_FORMAT  = '%d.%m.%y'

      OUTCOME_MAPPINGS = {
        'Undertakings'               => 'consumer-enforcement-undertakings',
        'Court order'                => 'consumer-enforcement-court-order',
        'No action'                  => 'consumer-enforcement-no-action',
        'markets - phase 1 referral' => 'markets-phase-1-referral',
        '?' => 'UNKNOWN'
      }

      def initialize(row)
        @row = row
      end

      def market_sector
        @row['Market sector']
      end

      def ref
        @row['Ref']
      end

      def outcome_type
        OUTCOME_MAPPINGS.fetch(@row['Outcome'])
      end

      def opened_date
        @_open_date ||= Row.parse_date(@row['Open date'])
      end

      def closed_date
        @_decision_date ||= Row.parse_date(@row['Closed date'])
      end

      def link
        @_link ||= CMA::Link.new(@row['Archive URL'])
      end

      def self.parse_date(date_str)
        return nil if date_str.nil?

        [SLASHED_DATE_FORMAT, DOTTED_DATE_FORMAT].find_yield do |format|
          begin
            Date.strptime(date_str, format)
          rescue ArgumentError
            nil
          end
        end.tap do |result|
          raise ArgumentError, 'invalid date' if result.nil?
        end
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
        Dir['sheets/*.csv'].map do |filename|
          Sheet.new(filename)
        end
      end.tap do |sheets|
        raise Errno::ENOENT, "No sheets found at #{Dir.pwd}" unless sheets.size > 0
      end
    end
  end
end
