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

      def initialize(row)
        @row = row
      end

      def market_sector
        @row['Market sector']
      end

      def ref
        @row['Ref']
      end

      def open_date
        Date.strptime(@row['Open date'], DATE_FORMAT)
      end

      def decision_date
        Date.strptime(@row['Decision date'], DATE_FORMAT)
      end

      def link
        CMA::Link.new(@row['Archive URL'])
      end
    end

    def rows
      @_rows ||= [].tap do |rows|
        CSV.foreach(filename, headers: true) do |row|
          rows << Row.new(row)
        end
      end
    end
  end
end
