require 'nokogiri'
require 'cma/cc/case'
require 'cma/link'

module CMA
  module CC
    module CaseList
      class Page
        attr_accessor :doc
        def initialize(doc)
          self.doc = doc
        end

        def old_case_links
          @old_case_links ||= doc.css('#listing .itemDetails a').map {|a| Link.new(a['href'], a.text) }
        end

        def cases
          @cases ||= old_case_links.map { |link| Case.from_link(link) }
        end

        def save_to(case_store)
          cases.each { |_case| case_store.save(_case) }
        end

        def self.from_html(doc)
          Page.new(doc)
        end
      end
    end
  end
end
