require 'anemone'
require 'cma/crawler/base'
require 'cma/asset'
require 'cma/oft/year_case_list'

module CMA
  module OFT
    ##
    # Crawl everything but mergers
    #
    class Crawler < CMA::Crawler::Base
      TNA_BASE      = 'http://webarchive.nationalarchives.gov.uk/20140402141250/'
      OFT_BASE      = 'http://www.oft.gov.uk/'
      CURRENT_CASES_ROOT = File.join(TNA_BASE, OFT_BASE, '/OFTwork/oft-current-cases/')

      ASSET = %r{(?<!Brie1)\.pdf$} # Delicious Brie1 actually a briefing note


      def canonicalize_uri(href)
        URI(href)
      end

      def link_nodes_for(page)
        page.doc.css('.body-copy a')
      end

      def focus_on_interesting_body_copy_links(crawl)
        crawl.focus_crawl do |page|
          next [] if page.doc.nil?

          hrefs_for(page).map do |href|
            if should_follow?(href)
              begin
                canonicalize_uri(href)
              rescue URI::InvalidURIError
                puts "MALFORMED URL: #{href} <- #{page.url}"
              end
            end
          end.compact

        end
      end

      def should_follow?(href)
        FOLLOW_ONLY.any? { |pattern| pattern =~ href } &&
          IGNORE_EXPLICITLY.none? { |pattern| pattern == href }
      end
    end
  end
end
