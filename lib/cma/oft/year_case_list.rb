require 'cma/link'
require 'cma/oft/case'
require 'cma/oft/mergers/case'

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

      def save_to(case_store, options = { noclobber: false })
        cases.each do |c|
          would_clobber = options[:noclobber] && case_store.exists?(c.original_url)
          case_store.save(c) unless would_clobber
        end
      end

    private
      def h1
        @_h1 ||= doc.at_css('.body-copy h1')
      end

      def missing_competition_case_2011?
        h1 && h1.text.include?('Competition case list 2011')
      end

      def market_references?
        h1 && h1.text.include?('Market investigation references')
      end

      def that_case
        Case.create(
          'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2011/access-control-alarm-systems',
          'Access control and alarm systems case'
        )
      end

      def old_case_links
        @old_case_links ||= begin
          all_old_case_links = doc.css('.body-copy li a').map do |a|
            Link.new(a['href'], a.text).tap do |link|
              if market_references?
                link.title.sub!(/ [\-0-9].*/, '')
              end
            end
          end
          all_old_case_links.reject {|link| link.original_url =~ Mergers::Case::SUBPAGE_NOT_CASE}
        end
      end
    end
  end
end

