require 'cma/oft/markets/case'
require 'cma/oft/crawler'
require 'cma/asset'
require 'cma/oft/year_case_list'

module CMA
  module OFT
    module Markets
      ##
      # Crawl markets only from one start URL
      #
      class Crawler < CMA::OFT::Crawler
        FOLLOW_ONLY = [
          Case::LIST,
          Case::CORE,
          Case::EXTRA_DETAIL,
          ASSET
        ]

        IGNORE_EXPLICITLY = [
          # Stuff that's on the market references page
          TNA_BASE + 'http://www.oft.gov.uk/shared_oft/business_leaflets/enterprise_act/oft833.pdf',
          TNA_BASE + 'http://www.oft.gov.uk/shared_oft/business_leaflets/enterprise_act/oft1308.pdf',
          TNA_BASE + 'http://www.oft.gov.uk/shared_oft/business_leaflets/enterprise_act/oft511.pdf'
        ]

        MARKET_REFERENCES = TNA_BASE + OFT_BASE + 'OFTwork/markets-work/references/'

        def create_or_update_content_for(page)
          original_url = CMA::Link.new(page.url).original_url
          case original_url
          when Case::LIST
            puts ' Case list'
            CMA::OFT::YearCaseList.new(page.doc).save_to(case_store)
          when Case::CORE
            puts ' Case'
            with_case(original_url, original_url) do |_case|
              _case.add_subpage(page.doc)
            end
          when Case::DETAIL, Case::EXTRA_DETAIL
            puts ' Detail'
            with_nearest_case_matching(page.referer, Case::CORE) do |_case|
              _case.add_subpage(page.doc)
            end
          when ASSET
            puts ' ASSET'
            with_nearest_case_matching(page.referer, Case::CORE) do |_case|
              asset = CMA::Asset.new(original_url, _case, page.body, page.headers['content-type'].first)
              asset.save!(case_store.location)
              _case.assets << asset
            end
          end
        end

        def crawl!
          do_crawl(MARKET_REFERENCES, newline_after_url: false, print_referer: false) do |crawl|
            focus_on_interesting_body_copy_links(crawl)
          end
        end

        def should_follow?(href)
          FOLLOW_ONLY.any? { |pattern| pattern =~ href } &&
            IGNORE_EXPLICITLY.none? { |pattern| pattern == href }
        end
      end
    end
  end
end
