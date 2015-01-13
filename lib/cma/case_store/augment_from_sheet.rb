require 'cma/case_store'
require 'cma/case_store/index'
require 'cma/sheet'
require 'cma/schema'

module CMA
  class CaseStore
    class AugmentFromSheet
      attr_accessor :case_store, :sheet
      def initialize(case_store, sheet)
        self.case_store = case_store
        self.sheet      = sheet
      end

      def index
        @_index ||= CMA::CaseStore::Index.new(case_store.location)
      end

      def schema
        @_schema ||= CMA::Schema.new
      end

      def run!(logger = Logger.new(STDERR))
        sheet.rows.each do |row|
          begin
            original_url = row.link.original_url
            filename = index[original_url]

            if filename && case_store.file_exists?(filename)
              case_store.load(filename).tap do |_case|
                _case.opened_date   = row.opened_date
                _case.closed_date   = row.closed_date
                _case.market_sector = schema.market_sector[row.market_sector]
                _case.outcome_type  = row.outcome_type
                case_store.save(_case)
              end
            else
              logger.warn "WARNING: case for #{original_url} not in index"
            end
          rescue => e
            logger.error("\n#{e.message} in row:\n\n#{row}")
          end
        end
      end
    end
  end
end
