require 'cma/oft/crawler'
require 'cma/case_store/index'

module CMA
  module OFT
    module Competition
      ##
      # Crawl completed competition/ca98/criminal cases
      #
      class Crawler < CMA::OFT::Crawler
        CA98_CLOSURE      = OFT_BASE + 'OFTwork/competition-act-and-cartels/ca98/closure/'
        CA98_COMPLETED    = OFT_BASE + 'OFTwork/competition-act-and-cartels/ca98/'
        CARTELS_COMPLETED = OFT_BASE + 'OFTwork/competition-act-and-cartels/criminal-cartels-completed/'

        CASE_DETAIL        =
          %r{
            /OFTwork/
            (?:
              (?:competition-act-and-cartels(?:/ca98(-current)?(?:/closure)?)?)
            )
            # Don't match any of the lists
            (?!/decisions/?$)
            (?!/closure/?$)
            (?!/ca98/?$)

            # But /decisions/<case> is ok
            (?:/decisions)?/[a-z|A-Z|0-9|_|-]+/?$
          }x

        FOLLOW_ONLY = [
         CASE_DETAIL,
         ASSET
        ]
        IGNORE_EXPLICITLY = [
          TNA_BASE + OFT_BASE + 'OFTwork/competition-act-and-cartels/competition-law-compliance/',
          TNA_BASE + OFT_BASE + 'OFTwork/competition-act-and-cartels/ca98-current/',
          TNA_BASE + OFT_BASE + 'OFTwork/competition-act-and-cartels/ca98/closure/motor-insurance-qanda/',
          TNA_BASE + OFT_BASE + 'OFTwork/competition-act-and-cartels/ca98-current/commercial-vehicle-criminal/',
          TNA_BASE + 'http://stg-new-oft:8080/OFTwork/competition-act-and-cartels/ca98-current/commercial-vehicle-criminal/'
        ]

        def link_nodes_for(page)
          # There's an additional sidebar we need to extract PDF links from, only
          # if the page we're parsing is a CASE_DETAIL page
          if page.url.to_s =~ CMA::OFT::Competition::Crawler::CASE_DETAIL
            page.doc.css('.body-copy a, #ID5 a.pdf-doc')
          else
            page.doc.css('.body-copy a')
          end
        end

        def should_follow?(href)
          FOLLOW_ONLY.any? { |pattern| pattern =~ href } &&
            IGNORE_EXPLICITLY.none? { |pattern| pattern == href }
        end

        def create_or_update_content_for(page)
          original_url = CMA::Link.new(page.url).original_url

          case original_url
          when CA98_CLOSURE, CA98_COMPLETED, CARTELS_COMPLETED
            puts ' Case List'
            CMA::OFT::YearCaseList.new(page.doc).save_to(
              case_store, noclobber: true)
          when CASE_DETAIL
            puts ' Case Detail'
            begin
              with_case(original_url, original_url) do |_case|
                _case.body = _case.sanitised_body_content(page.doc, header_offset: 1)
              end
            rescue Errno::ENOENT
              puts "WARN: no case found for #{original_url}"
            end
          when ASSET
            puts ' ASSET'
            return if page.referer.to_s =~ /doorstep-selling/

            begin
              with_nearest_case_matching(page.referer, CASE_DETAIL) do |_case|
                asset = CMA::Asset.new(original_url, _case, page.body, page.headers['content-type'].first)
                asset.save!(case_store.location)
                _case.assets << asset
              end
            rescue Errno::ENOENT
              puts "WARN: no case found for #{CMA::Link.new(page.referer).original_url} while trying to add asset #{original_url}"
            end
          end
        end

        def crawl!
          CMA::Filename::MAPPINGS.delete_if { true }

          [
            CA98_CLOSURE,
            CA98_COMPLETED,
            CARTELS_COMPLETED,
          ].map { |original_url| TNA_BASE + original_url }.each do |start_url|
            do_crawl(start_url,
                     newline_after_url: false) do |crawl|
              focus_on_interesting_body_copy_links(crawl)
            end
          end
        end
      end
    end
  end
end
