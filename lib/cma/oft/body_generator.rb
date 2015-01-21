require 'kramdown'
require 'cma/case_store'

module CMA
  module OFT
    class BodyGenerator
      attr_accessor :_case

      def initialize(_case)
        self._case = _case
      end

      def generate!
        _case.body = ''.tap do |body|
          _case.markup_sections.each_pair do |name, section_body|
            Kramdown::Document.new(
              section_body, header_offset: 1
            ).tap do |tree|
              body << tree.to_kramdown
            end
          end
        end
      end

      def self.case_store
        @@case_store ||= CMA::CaseStore.new
      end

      def self.case_filenames
        filenames = Dir[File.join(case_store.location, 'OFTwork-mergers-Mergers_Cases-200*.json')].concat(
                    Dir[File.join(case_store.location, 'OFTwork-markets-work-references*.json')])

        raise ArgumentError, "Nothing found in #{case_store.location}" if filenames.empty?

        filenames.map do |f|
          File.basename(f)
        end
      end

      def self.generate!
        case_filenames.each do |filename|
          _case = case_store.load(filename)

          puts "Generating body for #{filename}"
          BodyGenerator.new(_case).generate!
          case_store.save(_case)
        end
      end
    end
  end
end
