require 'cma/oft/case'

module CMA
  module OFT
    module Mergers
      class Case < CMA::OFT::Case
        def case_type
          'mergers'
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

        def add_summary(doc)
          raise ArgumentError,
                "#{original_url} is not a new-style case" unless new_style?

          self.summary = doc.at_css('.body-copy h1').text.strip
        end
      end
    end
  end
end
