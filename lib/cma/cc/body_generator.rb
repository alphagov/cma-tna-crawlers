require 'cma/case_store'
require 'kramdown'

module CMA
  module CC
    class BodyGenerator
      attr_accessor :_case

      def initialize(_case)
        self._case = _case
      end

      def generate!
        _case.body = "## Phase 2\n\n"

        _case.body << "Date of referral:  #{reformat_date(_case.date_of_referral)}\n"
        _case.body <<
          "Statutory deadline:  #{reformat_date(_case.statutory_deadline)}\n" if _case.statutory_deadline
        _case.body << "\n"

        append_single_sections(
          %w(
            core_documents
            remittal
            undertakings-and-order
            final_report
            provisional-final-report
            annotated-issues-statement
          )
        )

        append_subsections(
          %w(
            evidence
            analysis
          )
        )

        append_single_sections(
          %w(
            news-releases
            news-releases-announcements
          )
        )

        append_oft_sections
      end

      def append_subsections(subsection_names)
        subsection_names.each do |prefix|
          in_order_subsections = _case.markup_sections.keys.select do |section_name|
            section_name =~ Regexp.new("^#{prefix}/")
          end

          in_order_subsections.each do |section_name|
            _case.markup_sections[section_name].tap do |content|
              _case.body << Kramdown::Document.new(content, header_offset: 1).to_kramdown
            end
          end
        end
      end

      def append_bodies(bodies, options = { header_offset: 1 })
        bodies.each do |section_body|
          Kramdown::Document.new(
            section_body, header_offset: options[:header_offset]
          ).tap do |tree|
            _case.body << tree.to_kramdown
          end
        end
      end

      def append_single_sections(section_names)
        bodies = section_names.map { |cc_section_name| _case.markup_sections[cc_section_name] }.compact

        append_bodies(bodies)
      end


      def reformat_date(value)
        Date.strptime(value, '%Y-%m-%d').strftime('%d/%m/%Y') rescue 'N/A'
      end

      def append_oft_sections
        bodies = _case.markup_sections.inject([]) do |bodies, name_content|
          bodies << name_content.last if name_content.first =~ %r{OFT/}
          bodies
        end

        if bodies.any?
          _case.body << "\n## Phase 1\n"

          append_bodies(bodies, header_offset: 2)
        end
      end

      def self.case_store
        @@case_store ||= CMA::CaseStore.new
      end

      def self.case_filenames
        Dir[File.join(case_store.location, 'our-work*.json')].map do |f|
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
