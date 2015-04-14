require 'anemone'
require 'cma/crawler/base'
require 'cma/cc/case_list/page'
require 'cma/cc/case'
require 'cma/asset'

module CMA
  module CC
    class Crawler < CMA::Crawler::Base
      ATOZ              = %r{/our-work/directory-of-all-inquiries/?\?bytype=atoz&byid=[a-z]$}
      CASE              = %r{/our-work/directory-of-all-inquiries/[a-z|A-Z|0-9|-]+$}
      SUBPAGE           = %r{/our-work/directory-of-all-inquiries/[a-z|A-Z|0-9|-]+/[a-z|A-Z|0-9|-]+(?:/[a-z|A-Z|0-9|-]+)?/?$}
      ASSET             = %r{/assets/.*\.pdf$}

      FOLLOW_ONLY = [ATOZ, CASE, SUBPAGE, ASSET]
      IGNORE_EXPLICITLY = %w(
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/aggregates-cement-ready-mix-concrete
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/akzo-nobel-metlac
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/anglo-american-lafarge
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/breedon-aggregates-aggregate-industries
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/cineworld-city-screen
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/ericsson-creative
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/eurotunnel-seafrance
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/global-radio-gmg-merger-inquiry
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/northern-ireland-electricity-price-determination
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/omnicell-surgichem
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/payday-lending
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/private-healthcare-market-investigation
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/private-motor-insurance-market-investigation
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/review-of-ims-health-incorporated-undertakings
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/ryanair-aer-lingus
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/statutory-audit-services
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/tradebe-sita
        http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/verizon-vodafone-appeal
      )

      ##
      # Context-sensitive set of links per page
      def link_nodes_for(page)
        nodes  = page.doc.css('#mainColumn a')
        if [CASE, SUBPAGE].any? { |match| page.url.to_s =~ match }
          nodes += page.doc.css('#leftNavigation a')
        end
        nodes
      end

      def create_or_update_content_for(page)
        original_url = CMA::Link.new(page.url).original_url
        case original_url
        when ATOZ
          CMA::CC::CaseList::Page.new(page.doc).save_to(case_store)
        when CASE
          with_case(original_url, original_url) do |_c|
            _c.add_case_detail(page.doc)
          end
        when SUBPAGE
          with_nearest_case_matching(page.referer, CASE, original_url) do |c|
            c.add_markdown_detail(page.doc, case_relative_path(original_url))
          end
        when ASSET
          with_nearest_case_matching(page.referer, CASE) do |_case|
            asset = CMA::Asset.new(original_url, _case, page.body, page.headers['content-type'].first)
            asset.save!(case_store.location)
            _case.assets << asset
          end
        end
      end

      SUBPAGE_PARSE = %r{/our-work/directory-of-all-inquiries/[a-z|A-Z|0-9|-]+/([a-z|A-Z|0-9|-]+(/[a-z|A-Z|0-9|-]+)?)/?$}
      ##
      # Given a URL like http://cc.org.uk/our-work/directory-of-all-inquiries/aggregates/some-page/another-page,
      # return a path relative to the case, like some-page/another-page,
      # or raise +ArgumentError+ if the URL is not for a SUBPAGE
      def case_relative_path(url)
        url = url.to_s
        raise ArgumentError unless url =~ SUBPAGE_PARSE
        $1.downcase
      end

      def normalize_uri(href)
        URI(href.gsub(' ', ''))
      end

      TNA_BASE  = 'http://webarchive.nationalarchives.gov.uk/20140402141250/'
      CC_BASE   = 'http://www.competition-commission.org.uk/'
      DIRECTORY_A_TO_Z = File.join(TNA_BASE, CC_BASE, '/our-work/directory-of-all-inquiries?bytype=atoz&byid=a')

      def crawl!
        do_crawl(DIRECTORY_A_TO_Z) do |crawl|

          crawl.focus_crawl do |page|
            next [] if page.doc.nil?

            hrefs_for(page).map do |href|
              if should_follow?(href)
                begin
                  normalize_uri(href)
                rescue URI::InvalidURIError
                  puts "MALFORMED URL: #{href} <- #{page.url}"
                end
              end
            end.compact
          end
        end
      end

      def should_follow?(href)
        FOLLOW_ONLY.any? { |pattern| pattern =~ href } &&
          !IGNORE_EXPLICITLY.any? { |open_case_url| href.include?(open_case_url) }
      end

    end
  end
end
