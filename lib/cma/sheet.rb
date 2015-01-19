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
        'Court Order'                => 'consumer-enforcement-court-order',
        'No action'                  => 'consumer-enforcement-no-action',
        'markets - phase 1 referral' => 'markets-phase-1-referral',
        'No grounds for action'      => 'ca98-no-grounds-for-action-non-infringement',
        'No grounds for action/non-infringement' =>
                                        'ca98-no-grounds-for-action-non-infringement',
        'No gounds for action/non-infringement' =>
                                        'ca98-no-grounds-for-action-non-infringement',
        'Administrative priorities'  => 'ca98-administrative-priorities',
        'Infringement of Chapter I'  => 'ca98-infringement-chapter-i',
        'Infringement of Chapter II' => 'ca98-infringement-chapter-ii',
        'Infringement of Chapter  II' => 'ca98-infringement-chapter-ii',
        'Commitments' => 'ca98-commitment',
        'Criminal cartels - verdict' => 'criminal-cartels-verdict',
        'Regulatory appeals and references - final determination' =>
          'regulatory-references-and-appeals-final-determination',
        '?' => 'UNKNOWN'
      }

      SECTOR_MAPPINGS = {
        'Distribution and Services Industries' => 'distribution-and-service-industries',
        'Distribution and services industries' => 'distribution-and-service-industries',
        'Mineral extraction, mining ang quarrying' => 'mineral-extraction-mining-and-quarrying',
        'Agriculture, environment and nattural resources' => 'agriculture-environment-and-natural-resources',
        'Agriculture' => 'agriculture-environment-and-natural-resources',
        'Fire, police and security' => 'fire-police-and-security'
      }

      CASE_TYPE_MAPPINGS = {
        'Mergers' => 'mergers',
        'Reviews of orders and undertakings' => 'review-of-orders-and-undertakings',
        'Regulatory references and appeals' => 'regulatory-references-and-appeals'
      }

      def initialize(row)
        @row = row
      end

      def case_type
        CASE_TYPE_MAPPINGS[@row['Case type']]
      end

      def title
        title = @row['Title'] || @row['Title ']
        title.strip if title
      end

      def market_sector
        sector_title = @row['Market sector'] || @row['New CMA market sector']
        sector_title.strip! if sector_title

        SECTOR_MAPPINGS[sector_title] ||
          CMA::Schema.instance.market_sector[sector_title]
      end

      def ref
        @row['Ref']
      end

      def raw
        @row
      end

      def outcome_type
        outcome_title = @row['Outcome'] || @row['Outcome type']
        outcome_title.strip! if outcome_title

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
        url_str = @row['Archive URL']
        url_str.sub!('OFT closed case: ', '')
        @_link ||= CMA::Link.new(url_str)
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
