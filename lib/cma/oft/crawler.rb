require 'anemone'
require 'cma/crawler/base'

module CMA
  module OFT
    ##
    # Crawl everything but mergers
    #
    class Crawler < CMA::Crawler::Base
      # Just the page with A-Z links and order by links, no data, e.g.
      # http://webarchive.nationalarchives.gov.uk/20140402163422/http://www.oft.gov.uk/OFTwork/oft-current-cases/market-studies-2005/
      CASE_LIST_INTERSTITIAL =
        %r{
          /OFTwork/oft-current-cases/
          (((competition|consumer)-case-list-20[0-9]{2})|
          (markets?-(studies|work)-[0-9]{4}))
          /?$
        }x

      # A usable list of cases once we've ordered by date, e.g.
      # http://webarchive.nationalarchives.gov.uk/20140402163422/http://www.oft.gov.uk/OFTwork/oft-current-cases/market-studies-2005/?Order=Date&currentLetter=A
      CASE_LIST_FOR_YEAR =
        %r{
          /OFTwork/oft-current-cases/
          (((competition|consumer)-case-list-20[0-9]{2})|(markets?-(studies|work)-[0-9]{4}))
          /\?Order=Date(?:&.*)?$
        }x
      CASE =
        %r{
          /OFTwork/oft-current-cases/
          (((competition|consumer)-case-list-20[0-9]{2})|(markets?-(studies|work)-[0-9]{4}))
          /[a-z|A-Z|0-9|-]+/?$
      }x
      CASE_DETAIL        =
        %r{
          /OFTwork/
          (?:
            (?:competition-act-and-cartels|consumer-enforcement)|
            (?:markets-work|(?:oft-current-cases/market-studies-[0-9]{4}))|
            (?:consumer-enforcement/consumer-enforcement-completed)
          )
          /[a-z|A-Z|0-9|-]+/?$
        }x

      ASSET              = %r{(?<!Brie1)\.pdf$} # Delicious Brie1 actually a briefing note

      FOLLOW_ONLY = [
        CASE_LIST_INTERSTITIAL,
        CASE_LIST_FOR_YEAR,
        CASE,
        CASE_DETAIL,
        ASSET
      ]

      ##
      # Context-sensitive set of links per page
      def link_nodes_for(page)
        nodes = page.doc.css('.body-copy a')

        # We don't want cases directly from the current work root,
        # as they were active and have already been attended to
        if page.url.to_s == CURRENT_CASES_ROOT then
          nodes.reject { |a| a['href'] && a['href'] =~ CASE }
        else
          nodes
        end
      end

      def create_or_update_content_for(page)
        original_url = CMA::Link.new(page.url).original_url
        case original_url
        when CASE_LIST_INTERSTITIAL then puts ' Interstitial'
        when CASE_LIST_FOR_YEAR     then puts ' Year Case list'
        when CASE                   then puts ' Case'
        when CASE_DETAIL            then puts ' Case Detail'
        when ASSET                  then puts ' ASSET'
        end
      end

      TNA_BASE      = 'http://webarchive.nationalarchives.gov.uk/20140402141250/'
      OFT_BASE      = 'http://www.oft.gov.uk/'
      CURRENT_CASES_ROOT = File.join(TNA_BASE, OFT_BASE, '/OFTwork/oft-current-cases/')

      def crawl!
        do_crawl(CURRENT_CASES_ROOT, newline_after_url: false) do |crawl|

          crawl.focus_crawl do |page|
            next [] if page.doc.nil?

            link_nodes_for(page).map do |a|
              next unless (href = a['href'])

              if FOLLOW_ONLY.any? { |pattern| pattern =~ href }
                begin
                  URI(href)
                rescue URI::InvalidURIError
                  puts "MALFORMED URL: #{href} <- #{page.url}"
                end
              end
            end.compact

          end
        end
      end

    end
  end
end
