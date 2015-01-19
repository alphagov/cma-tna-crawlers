require 'cma/case_store'
require 'cma/case_store/index'
require 'cma/sheet'
require 'colorize'

module CMA
  class CaseStore
    class AugmentFromSheet
      attr_accessor :case_store, :sheet, :logger
      def initialize(case_store, sheet, logger = Logger.new(STDOUT))
        self.case_store = case_store
        self.sheet      = sheet
        self.logger     = logger
        logger.formatter = proc do |severity, datetime, progname, msg|
          severity_letter = severity[0]
          color = case severity_letter
            when 'W' then :yellow
            when 'E' then :red
            when 'I' then :green
          end
          "#{severity_letter.send(color)}: #{msg}\n"
        end
      end

      def index
        @_index ||= CMA::CaseStore::Index.new(case_store.location)
      end

      def run!
        sheet.rows.each do |row|
          begin
            original_url = row.link.original_url
            filename = index[original_url]

            if filename && case_store.file_exists?(filename)
              case_store.load(filename).tap do |_case|
                %i(opened_date closed_date outcome_type
                   title market_sector
                ).each do |field|
                  set(_case, row, field)
                end

                if _case.respond_to?(:case_type=) && row.case_type
                  set(_case, row, :case_type)
                end

                _case.modified_by_sheet = true
                case_store.save(_case)
              end
            else
              logger.warn "case for #{original_url} not in index"
            end
          rescue => e
            logger.error("#{e.message} in row\n#{row}")
          end
        end
      end

      def set(_case, row, field)
        value = block_given? ? yield : row.send(field)

        setter = "#{field}="
        value_set = _case.send(setter, value)

        logger.warn("#{field} nil for #{row.to_s.chomp}") unless value_set || field.to_s =~ /date/
      end
    end
  end
end
