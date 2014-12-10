require 'anemone'
require 'cma/crawler/base'
require 'cma/cc/case_list/page'
require 'cma/cc/case'

module CMA
  module CC
    module CaseList
      class Crawler < CMA::Crawler::Base
        ATOZ = %r{/our-work/directory-of-all-inquiries/?\?bytype=atoz&byid=[a-z]$}

        INTERESTED_ONLY_IN = [ATOZ]

        ##
        # Context-sensitive set of links per page
        def link_nodes_for(page)
          page.doc.css('#mainColumn a')
        end

        def create_or_update_content_for(page)
          original_url = CMA::Link.new(page.url).original_url
          if original_url =~ ATOZ
            CMA::CC::CaseList::Page.new(page.doc).save_to(case_store)
          end
        end

        TNA_BASE         = 'http://webarchive.nationalarchives.gov.uk/20140402141250/'
        CC_BASE          = 'http://www.competition-commission.org.uk/'
        DIRECTORY_A_TO_Z = File.join(TNA_BASE, CC_BASE, '/our-work/directory-of-all-inquiries?bytype=atoz')

        ##
        # Cases must all be there first before we bother with subpages
        # and assets. They're not all on one page...
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
end
