require 'cma/oft/case'

module CMA
  module OFT
    module Mergers
      class Case < CMA::OFT::Case
        ##
        # Nine subpages for cases that started 2009, but which appear
        # at new-style URLs (so would be incorrectly matched as 2010 cases
        # if left alone)
        SUBPAGE_NOT_CASE = %r{
          (london-stock-exchange|go-north-east|Aggregate|Koppers|arriva|
           co-op-psw|ambassador|co-operative1|phs-teacrate)
        }x

        attr_writer :case_type
        def case_type
          @case_type ||= 'mergers'
        end

        def old_style?
          !!(original_url =~ /200[0-9]/)
        end

        def new_style?
          !old_style?
        end

        def title_is_summary?
          new_style?
        end

        CLOSED_CASE_PREFIX = 'OFT closed case: '

        def add_summary(doc)
          raise ArgumentError,
                "#{original_url} is not a new-style case" unless new_style?

          self.summary = CLOSED_CASE_PREFIX +
            main_header_text(doc)
        end

        def add_subpage(doc)
          self.summary = CLOSED_CASE_PREFIX +
            main_header_text(doc)

          subpage_name = subpage_name_for(doc)
          markup_sections[subpage_name] = sanitised_body_content(doc)

          original_urls << www(original_url_from_meta(doc))
        end

      private
        def main_header_text(doc)
          doc.at_css('.body-copy h1').text.strip
        end

        def subpage_name_for(doc)
          original_url_from_meta(doc) =~ %r{mergers/(.*)$}
          $1
        end
      end
    end
  end
end
