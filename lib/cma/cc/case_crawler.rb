require 'anemone'
require 'cma/crawler/base'
require 'cma/cc/case_list/page'
require 'cma/cc/case'

module CMA
  module CC
    class CaseCrawler < CMA::Crawler::Base
      CASE              = %r{/our-work/directory-of-all-inquiries/[a-z|A-Z|0-9|-]+$}
      SUBPAGE           = %r{/our-work/directory-of-all-inquiries/[a-z|A-Z|0-9|-]+/[a-z|A-Z|0-9|-]+(?:/[a-z|A-Z|0-9|-]+)?/?$}
      ASSET             = %r{/assets/.*\.pdf$}

      INTERESTED_ONLY_IN = [CASE, SUBPAGE, ASSET]

      ##
      # Context-sensitive set of links per page
      def link_nodes_for(page)
        page.doc.css('#mainColumn a')
      end

      def create_or_update_content_for(page)
        original_url = CMA::Link.new(page.url).original_url
        case original_url
        when CASE
          with_case(original_url, original_url) do |_c|
            _c.add_case_detail(page.doc)
          end
        when SUBPAGE
          with_nearest_case_matching(page.referer, CASE, original_url) do |c|
            c.add_markdown_detail(page.doc, case_relative_path(original_url))
          end
        when ASSET
          puts "ASSET: #{original_url}"
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


      TNA_BASE  = 'http://webarchive.nationalarchives.gov.uk/20140402141250/'
      CC_BASE   = 'http://www.competition-commission.org.uk/'
      DIRECTORY_A_TO_Z = File.join(TNA_BASE, CC_BASE, '/our-work/directory-of-all-inquiries?bytype=atoz')

      def crawl!
        do_crawl(DIRECTORY_A_TO_Z) do |crawl|

          crawl.focus_crawl do |page|
            next [] if page.doc.nil?

            link_nodes_for(page).map do |a|
              next unless (href = a['href'])

              if INTERESTED_ONLY_IN.any? { |pattern| pattern =~ href }
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
