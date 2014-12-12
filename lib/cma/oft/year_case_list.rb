require 'cma/link'
require 'cma/oft/case'

module CMA
  module OFT
    class YearCaseList
      attr_accessor :doc
      def initialize(doc)
        self.doc = doc
      end

      def cases
        @cases ||= old_case_links.map { |link| Case.create(link.original_url, link.title) }
        missing_competition_case_2011? ? [@cases, that_case].flatten : @cases
      end

      def save_to(case_store)
        cases.each { |c| case_store.save(c) }
      end

    private
      def missing_competition_case_2011?
        h1 = doc.at_css('.body-copy h1')
        h1 && h1.text.include?('Competition case list 2011')
      end

      def that_case
        Case.create(
          'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2011/access-control-alarm-systems',
          'Access control and alarm systems case'
        )
      end

      def old_case_links
        @old_case_links ||= doc.css('.body-copy li a').map {|a| Link.new(a['href'], a.text) }
      end
    end
  end
end

