require 'cma/case'
require 'cma/markup_helpers'
require 'kramdown'
require 'kramdown/converter/kramdown_patched'

module CMA
  module OFT
    class Case < CMA::Case
      attr_accessor :summary, :body

      def case_type
        'unknown'
      end

      def add_summary(doc)
        self.summary = begin
          # Sports goods weirdness
          sports_goods_content = doc.at_xpath(
            '//div[@class="intro"]/p/br[6]/following-sibling::text()[string-length() > 2]')

          content = if sports_goods_content
                      sports_goods_content.content
                    else
                      doc.xpath(
                        "//div[contains(@class, 'intro')]/*[position() > 2]").inner_html.to_s
                    end

          to_kramdown(content)
        end
      end

      def to_kramdown(content)
        Kramdown::Document.new(content, input: 'html').to_kramdown.gsub(/\{:.+?}/m, '')
      end

      def add_detail(doc)
        doc.dup.at_css('.body-copy').tap do |body_copy|
          %w(div span script p.backtotop p.previouspage).each do |selector|
            body_copy.css(selector).remove
          end

          %w(
              //table/@*
              //a/@target
              //a[@name]
              //comment()
            ).each do |superfluous_nodes|
            body_copy.xpath(superfluous_nodes).each(&:unlink)
          end

          body_copy.remove_tna_part_from_hrefs!

          self.body = to_kramdown(body_copy.inner_html.to_s)
        end
      end

      def self.create(original_url, title)
        Case.new.tap do |c|
          c.title = title
          c.original_url = original_url
        end
      end
    end
  end
end
