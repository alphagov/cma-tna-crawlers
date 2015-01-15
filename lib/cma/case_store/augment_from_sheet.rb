require 'cma/case_store'
require 'cma/case_store/index'
require 'cma/sheet'
require 'cma/schema'

module CMA
  class CaseStore
    class AugmentFromSheet
      attr_accessor :case_store, :sheet, :logger
      def initialize(case_store, sheet, logger = Logger.new(STDOUT))
        self.case_store = case_store
        self.sheet      = sheet
        self.logger     = logger
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{severity[0]}: #{msg}\n"
        end
      end

      def index
        @_index ||= CMA::CaseStore::Index.new(case_store.location)
      end

      def schema
        @_schema ||= CMA::Schema.new
      end

      def run!
        sheet.rows.each do |row|
          begin
            original_url = row.link.original_url
            filename = index[original_url]

            if filename && case_store.file_exists?(filename)
              case_store.load(filename).tap do |_case|
                %i(opened_date closed_date outcome_type title).each do |field|
                  set(_case, row, field)
                end
                set(_case, row, :market_sector) do
                  schema.market_sector[row.market_sector]
                end

                case_store.save(_case)
              end
            else
              logger.warn "case for '#{original_url}' not in index"
            end
          rescue => e
            logger.error("#{e.message} in row\n#{row}")
            raise
          end
        end
      end

      def set(_case, row, field)
        value = block_given? ? yield : row.send(field)

        setter = "#{field}="
        _case.send(setter, value) or
          logger.warn("#{field} nil for #{row.to_s.chomp}")
      end
    end
  end
end
