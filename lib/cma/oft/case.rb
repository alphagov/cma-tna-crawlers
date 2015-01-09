require 'cma/case'
require 'cma/markup_helpers'
require 'kramdown'
require 'kramdown/converter/kramdown_patched'

module CMA
  module OFT
    class Case < CMA::Case
      def case_type
        'unknown'
      end

      def to_kramdown(content)
        Kramdown::Document.new(content, input: 'html').to_kramdown.gsub(/\{:.+?}/m, '')
      end

      # <meta name="DC.identifier" scheme="DCTERMS.URI"
      #   content="http://oft.gov.uk/OFTwork/markets-work/taxis" />
      def original_url_from_meta(doc)
        doc.at_xpath(
          '//head/meta[@name="DC.identifier"][@scheme="DCTERMS.URI"]/@content'
        ).to_s.sub(%r{://oft\.}, '://www.oft.')
      end

      def self.create(original_url, title)
        self.new.tap do |c|
          c.title = title
          c.original_url = original_url
        end
      end
    end
  end
end
