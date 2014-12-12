require 'cma/link'

module CMA
  module OFT
    class YearCaseList
      attr_accessor :doc
      def initialize(doc)
        self.doc = doc
      end

      def cases
        @cases ||= old_case_links.map { |link| Struct.new(:title, :original_url).new(link.title, link.original_url) }
      end

      def save_to(case_store)
        cases.each { |c| case_store.save(c) }
      end

    private
      def old_case_links
        @old_case_links ||= doc.css('.body-copy li a').map {|a| Link.new(a['href'], a.text) }
      end
    end
  end
end

