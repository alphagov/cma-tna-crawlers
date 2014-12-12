require 'cma/case'

module CMA
  module OFT
    class Case < CMA::Case
      attr_accessor :summary, :body

      def case_type
        'unknown'
      end

      def add_summary(doc)
        self.summary = doc.at_xpath('//div[@class="intro"]/p[2]').content
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
