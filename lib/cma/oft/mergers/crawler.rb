require 'cma/oft/crawler'
require 'cma/case_store/index'
require 'cma/oft/mergers/case'

module CMA
  module OFT
    module Mergers

      ##
      # Crawl mergers cases
      #
      class Crawler < CMA::Crawler::Base
        TNA_BASE      = 'http://webarchive.nationalarchives.gov.uk/20140402141250/'
        OFT_BASE      = 'http://www.oft.gov.uk/'

        CASE_LIST = %r{
          OFTwork/mergers/
          (
            (decisions/201[0-9]/?)|
            (Mergers_Cases/200[0-9]/?\?Order=Date&currentLetter=A)
          )
          /?$
        }x

        CASE      = %r{
          OFTwork/mergers/
          (?:
            ( # 2010-14 cases pages are only at /decisions

              decisions/201[0-9]

              # ... but there are exceptions; decisions that came later on an
              # "old-style" case.
              # List them here.

              (?!/#{Case::SUBPAGE_NOT_CASE})
            )|
            (Mergers_Cases/200[0-9])  # 2002-09 cases pages are at /Mergers_Cases
          )
          /[a-z|A-Z|0-9|_|-]+/?$
        }x

        SUBPAGE = %r{
          OFTwork/mergers/
          (decisions/200[0-9]/[a-z|A-Z|0-9|_|-]+/?$)|
          (decisions/2010/#{Case::SUBPAGE_NOT_CASE})
        }x

        ASSET     = %r{(?<!Brie1)\.pdf$} # Delicious Brie1 actually a briefing note

        FOLLOW_ONLY = [CASE, SUBPAGE, ASSET]
        IGNORE_EXPLICITLY = [
          # Duplicate of .../capita differing only by 'C'
          'http://webarchive.nationalarchives.gov.uk/20140402142426/http://www.oft.gov.uk/OFTwork/mergers/decisions/2013/Capita'
        ]

        def create_or_update_content_for(page)
          original_url = CMA::Link.new(page.url).original_url

          case original_url
          when CASE_LIST
            puts ' Case list'
            CMA::OFT::YearCaseList.new(page.doc).save_to(case_store, noclobber: true)
          when CASE
            puts ' Case'
            with_case(original_url) do |_case|
              if _case.new_style?
                _case.add_summary(page.doc)
                _case.body = _case.sanitised_body_content(page.doc) if _case.needs_fntq_body?(page.doc)
              end
            end
          when SUBPAGE
            if decision_from_2009_case?(original_url, page)
              puts "\nSKIPPING: #{original_url}"
              return
            end

            puts ' Subpage'
            begin
              with_nearest_case_matching(page.referer, CASE) do |_case|
                _case.add_subpage(page.doc)
              end
            rescue Errno::ENOENT
              puts "\nWARNING: no case for SUBPAGE #{original_url}\n"
              dump_referer_chain(page, 1)
              puts
            end
          when ASSET
            puts ' ASSET'
            begin
              with_nearest_case_matching(page.referer, CASE) do |_case|
                asset = CMA::Asset.new(original_url, _case, page.body, page.headers['content-type'].first)
                asset.save!(case_store.location)
                _case.assets << asset
              end
            rescue Errno::ENOENT
              puts "WARNING: no case for ASSET #{original_url}"
              dump_referer_chain(page, 1)
              puts
            end
          end
        end

        def decision_from_2009_case?(original_url, page)
          original_url =~ Case::SUBPAGE_NOT_CASE &&
            page.referer.to_s =~ %r{mergers/decisions/2010/?$}
        end

        def crawl!
          merger_entry_points.each do |start_url|
            do_crawl(start_url,
                     newline_after_url: false) do |crawl|
              focus_on_interesting_body_copy_links(crawl)
            end
          end
        end

        def merger_entry_points
          %w(
            OFTwork/mergers/decisions/2014/
            OFTwork/mergers/decisions/2012/
            OFTwork/mergers/decisions/2013/
            OFTwork/mergers/decisions/2011/
            OFTwork/mergers/decisions/2010/
          ).map {|path| TNA_BASE + OFT_BASE + path}
        end

        def focus_on_interesting_body_copy_links(crawl)
          crawl.focus_crawl do |page|
            next [] if page.doc.nil?

            link_nodes_for(page).map do |a|
              next unless (href = a['href'])

              if should_follow?(href)
                begin
                  URI(href)
                rescue URI::InvalidURIError
                  puts "MALFORMED URL: #{href} <- #{page.url}"
                end
              end
            end.compact

          end
        end

        def should_follow?(href)
          FOLLOW_ONLY.any? { |pattern| pattern =~ href } &&
            IGNORE_EXPLICITLY.none? { |url| url == href }
        end

        def link_nodes_for(page)
          page.doc.css('.body-copy a')
        end
      end
    end
  end
end
