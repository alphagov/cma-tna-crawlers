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
          (((competition|consumer)-case-list-20[0-9]{2})|(markets?-(studies|work)-?[0-9]{4}))
          /[a-z|A-Z|0-9|-]+/?$
        }x
      CASE_DETAIL        =
        %r{
          /OFTwork/
          (?:
            (?:competition-act-and-cartels(?:/ca98(-current)?(?:/closure)?)?)|
            (?:markets-work|(?:oft-current-cases/market-studies-[0-9]{4}))|
            (?:consumer-enforcement/consumer-enforcement-completed)
          )
          (?!/criminal-cartels-completed/?$)
          (?!/completed/?$)
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

      IGNORE_EXPLICITLY = [
        # Does not exist in TNA at this or other timestamps
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2014/?Order=Date&currentLetter=A',
        # Does not exist in TNA at this or other timestamps
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/oft-current-cases/consumer-case-list-2013/air-travel',
        # Not in current or completed cases pages, or linked to from anywhere except other case pages (Pegasus)
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/consumer-enforcement/consumer-enforcement-completed/retirement-homes/',
        # FIXME: No way to handle this - nested, not single CASE_DETAIL
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/markets-work/hombuilding-updates',
        # FIXME: No way to handle this - nested, not single CASE_DETAIL
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/markets-work/secondhandcarsqanda',
        # FIXME: Generalised help document
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/markets-work/QandAs',
        # FIXME: Generalised help document
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/markets-work/homebuying-and-selling-QandAs',
        # FIXME: Generalised help document
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/markets-work/consumer-contracts-QandAs',
        # FIXME: Generalised help document
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/markets-work/market-studies-further-info/',
        # Woah, what?
        TNA_BASE + 'http://stg-new-oft:8080/OFTwork/competition-act-and-cartels/ca98-current/commercial-vehicle-criminal/'
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
        when CASE_LIST_FOR_YEAR
          puts ' Year Case list'
          CMA::OFT::YearCaseList.new(page.doc).save_to(case_store)
        when CASE
          puts ' Case'
          with_case(original_url, original_url) do |_case|
            _case.add_summary(page.doc)
          end
        when CASE_DETAIL
          puts ' Case Detail'
          with_nearest_case_matching(page.referer, CASE) do |_case|
            _case.add_detail(page.doc)
          end
        when ASSET
          puts ' ASSET'
          with_nearest_case_matching(page.referer, CASE) do |_case|
            asset = CMA::Asset.new(original_url, _case, page.body, page.headers['content-type'].first)
            asset.save!(case_store.location)
            _case.assets << asset
          end
        end
      end

      def crawl!
        do_crawl(CURRENT_CASES_ROOT, newline_after_url: false, print_referer: true) do |crawl|
          focus_on_interesting_body_copy_links(crawl)
        end
      end

      def focus_on_interesting_body_copy_links(crawl)
        crawl.focus_crawl do |page|
          next [] if page.doc.nil?

          link_nodes_for(page).map do |a|
            next unless (href = a['href'])

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

      # aka how to sidestep TNA 302 redirect landmines.
      # Add things here to point to a canonical version of a URL (if, for example, another
      # version of the URL exists that isn't linked to from the case pages)
      MAPPINGS = {
        TNA_BASE + 'http://www.oft.gov.uk/OFTwork/markets-work/doorstep-selling' =>
          TNA_BASE + 'http://www.oft.gov.uk/OFTwork/markets-work/super-complaints/doorstep-selling'
      }
      def canonicalize_uri(href)
        href = MAPPINGS[href] || href
        URI(href)
      end

    end
  end
end
