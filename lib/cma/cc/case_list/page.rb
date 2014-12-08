require 'nokogiri'

module CMA
  module CC
    module CaseList
      class Page
        attr_accessor :doc
        def initialize(doc)
          self.doc = doc
        end

        def first_page?
          @first_page ||= (doc.css('.atoz li strong').text == 'A')
        end

        def old_case_links
          @old_case_links ||= doc.css('#listing .itemDetails a').map {|a| Link.new(a['href'], a.text) }
        end

        def letter_page_links
          return [] unless first_page?
          @letter_page_links ||= doc.css('.atoz a').map {|a| Link.new(a['href'], a.text)}
        end

        def self.from_html(doc)
          Page.new(doc)
        end
      end
    end
  end
end
