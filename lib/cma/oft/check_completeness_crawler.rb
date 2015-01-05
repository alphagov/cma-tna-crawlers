require 'cma/oft/crawler'
require 'cma/case_store'
require 'cma/case_store/index'
require 'cma/link'

module CMA
  module OFT
    ##
    #
    # For a given set of pages, check if our default OFT crawl strategy is
    # enough by testing for their existence in the case store.
    #
    # WARNING: dependent on the full output of bin/crawl_oft.rb
    #
    class CheckCompletenessCrawler < CMA::OFT::Crawler
      START_URLS = %w(
        http://www.oft.gov.uk/OFTwork/competition-act-and-cartels/criminal-cartels-completed/
        http://www.oft.gov.uk/OFTwork/consumer-enforcement/consumer-enforcement-completed/
        http://www.oft.gov.uk/OFTwork/markets-work/completed/
      ).map { |url| TNA_BASE + url }

      def dont_exist
        @dont_exist ||= Set.new
      end

      def index
        @_index = CMA::CaseStore::Index.new(case_store.location)
      end

      def create_or_update_content_for(page)
        original_url = Link.new(page.url).original_url
        if case?(original_url) && index[original_url].nil?
          dont_exist << original_url
        end
      end

      def case?(original_url)
        original_url =~ CASE || original_url =~ CASE_DETAIL
      end

      def crawl!
        FOLLOW_ONLY.delete(ASSET)

        START_URLS.each do |start_url|
          do_crawl(start_url) do |crawl|
            focus_on_interesting_body_copy_links(crawl)
          end
        end

        case_store.save(
          { 'dont_exist' => dont_exist },
          '_existence_report.json'
        )
      end
    end
  end
end
