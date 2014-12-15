require 'nokogiri'
require 'cma/link'

module CMA
  module MarkupHelpers
    def remove_tna_part_from_hrefs!
      xpath('.//a').reject {|a| a['href'].nil? }.each do |a|
        link = Link.new(a['href'])
        a['href'] = link.original_url
      end
    end

    def at_first_xpath(*xpaths)
      result = nil
      xpaths.find do |xpath|
        result = at_xpath(xpath)
      end
      result
    end
  end
end

Nokogiri::XML::Node.class_eval do
  include CMA::MarkupHelpers
end
