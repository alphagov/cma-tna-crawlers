require 'cma/case'
require 'kramdown'
require 'kramdown/converter/kramdown_patched'
require 'nokogiri'
require 'cma/markup_helpers'

module CMA
  module CC
    class Case < CMA::Case
      include ActiveModel::Serializers::JSON

      attr_accessor :date_of_referral, :statutory_deadline

      # Case type is overwritable for CC cases
      attr_writer :case_type
      def case_type
        @case_type ||= case title
                       when /merger inquir(y|ies)/ then
                         'mergers'
                       when /market investigation/ then
                         'markets'
                       else
                         'unknown'
                       end
      end

      def self.from_link(link)
        Case.create(link.original_url, link.title)
      end

      def add_case_detail(doc)
        self.date_of_referral   = parse_date_at_xpath(
          doc, [possible_date_position_1(2), possible_date_position_2(2)])
        self.statutory_deadline = parse_date_at_xpath(
          doc, [possible_date_position_1(3), possible_date_position_2(3)])

        add_markdown_detail(doc, 'core_documents')
      end

      def add_markdown_detail(doc, markup_sections_path)
        doc.dup.at_css('#mainColumn').tap do |markup|
          # Simple stuff
          %w(div img script ul#pageOptions a#accesskey-skip).each { |tag| markup.css(tag).remove }

          # Move the thing that should just be li > a out from under its SiteCore
          # styling. Way to MsoNormal
          markup.css('li p.MsoNormal span a').each do |link|
            link.parent = link.at_xpath('ancestor::li')
          end

          # Stuff CSS can't handle, and stuff Kramdown can't either
          %w(
              //a[contains(text\(\),'Print')]
              //a[contains(text\(\),'RSS')]
              //span[not(contains(@class,'mediaLinkText'))]
              //a/@target
              //a/@name
              //a/@shape
              //a/@rel
              //@class
              //@style
              //table/@*
              //table//th/@valign
              //table//td/@valign
              //table//thead
              //comment()
            ).each do |superfluous_nodes|
            markup.xpath(superfluous_nodes).each(&:unlink)
          end

          markup.remove_tna_part_from_hrefs!

          markup.xpath('.//h2[1]/preceding-sibling::*').each(&:remove)

          # Move text in leftover spans that were .mediaLinkText
          # to the link as a parent
          markup.xpath('.//span').each do |span|
            text_node        = span.at_xpath('./text()')
            text_node.parent = span.parent if text_node
            span.remove
          end

          markup_sections[markup_sections_path] =
            Kramdown::Document.new(
              markup.inner_html.to_s,
              input: 'html'
            ).to_kramdown.gsub(/\{:.+?}/m, '')
        end
      end

      def self.create(original_url, title)
        Case.new.tap do |c|
          c.original_url  = original_url
          c.title = title
        end
      end

      private
      # Dates could be here
      def possible_date_position_1(index)
        "//div[@id='mainColumn']/h1/following-sibling::p/text()[#{index}]"
      end

      # Or here, depending on value of $WTFICANTEVEN
      def possible_date_position_2(index)
        "//div[@id='mainColumn']/h1/following-sibling::div/p[1]/text()[#{index}]"
      end

      def parse_date_at_xpath(doc, try_xpath)
        xpath = try_xpath.find { |xpath| doc.at_xpath(xpath) }
        return if (date_node = doc.at_xpath(xpath)).nil?
        date_node.text =~ /([0-9]{1,2}\.[0-9]{2}\.[0-9]{2})/
        Date.strptime($1, '%d.%m.%y') if xpath
      end
    end
  end
end
