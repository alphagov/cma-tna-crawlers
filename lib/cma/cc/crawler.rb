require 'anemone'

module CMA
  module CC
    class Crawler
      ATOZ              = %r{/our-work/directory-of-all-inquiries/?\?bytype=atoz&byid=[a-z]$}
      CASE              = %r{/our-work/directory-of-all-inquiries/[a-z|A-Z|0-9|-]+$}
      SUBPAGE           = %r{/our-work/directory-of-all-inquiries/[a-z|A-Z|0-9|-]+/[a-z|A-Z|0-9|-]+(?:/[a-z|A-Z|0-9|-]+)?/?$}
      ASSET             = %r{/assets/.*\.pdf$}

      INTERESTED_ONLY_IN = [ATOZ, CASE, SUBPAGE, ASSET]

      ##
      # Context-sensitive set of links per page
      def link_nodes_for(page)
        page.doc.css('#mainColumn a')
      end

      def create_or_update_content_for(page)

      end

      TNA_BASE  = 'http://webarchive.nationalarchives.gov.uk/20140402141250/'
      CC_BASE   = 'http://www.competition-commission.org.uk/'
      DIRECTORY_A_TO_Z = File.join(TNA_BASE, CC_BASE, '/our-work/directory-of-all-inquiries?bytype=atoz')

      def crawl!
        Anemone.crawl(DIRECTORY_A_TO_Z) do |crawl|

          crawl.on_every_page do |page|
            puts "#{page.code} #{page.url}#{' <- ' if page.referer}#{page.referer}"
            create_or_update_content_for(page)
          end

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
