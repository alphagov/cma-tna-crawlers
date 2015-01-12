require 'csv'
require 'cma/link'

module CMA
  class Sheet
    attr_accessor :filename

    def initialize(filename)
      self.filename = filename
    end

    class Row
      DATE_FORMAT = '%d/%m/%y'

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
        date_str = @row['Open date']
        @_open_date ||=
          Date.strptime(date_str, DATE_FORMAT) unless date_str.nil?
      end

      def closed_date
        @_decision_date ||=
          Date.strptime(@row['Closed date'], DATE_FORMAT)
      end

      def link
        @_link ||= CMA::Link.new(@row['Archive URL'])
      end
    end

    def rows
      @_rows ||= [].tap do |rows|
        CSV.foreach(filename, headers: true) do |row|
          rows << Row.new(row)
        end
      end
    end

    def Sheet.all
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
