require 'cma/case'
require 'cma/markup_helpers'
require 'kramdown'

module CMA
  module OFT
    class Case < CMA::Case
      attr_accessor :summary, :body

      def case_type
        'unknown'
      end

      def add_summary(doc)
        self.summary = begin
          content = doc.at_first_xpath(
            '//div[@class="intro"]/p[2]',
            '//div[@class="intro"]/ol'
          ).inner_html.to_s

          Kramdown::Document.new(content, input: 'html').to_kramdown.gsub(/\{:.+?}/m, '')
        end
      end

      def self.create(original_url, title)
        Case.new.tap do |c|
          c.title = title
          c.original_url = original_url
        end
      end
    end
  end
end
