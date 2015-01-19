require 'cma/oft/case'

module CMA
  module OFT
    module Mergers
      class Case < CMA::OFT::Case
        ##
        # Nine subpages for cases that started 2009, but which appear
        # at new-style URLs (so would be incorrectly matched as 2010 cases
        # if left alone)
        SUBPAGE_NOT_CASE = %r{
          (london-stock-exchange|go-north-east|Aggregate|Koppers|arriva|
           co-op-psw|ambassador|co-operative1|phs-teacrate)
        }x

        attr_writer :case_type
        def case_type
          @case_type ||= 'mergers'
        end

        def old_style?
          !!(original_url =~ /200[0-9]/)
        end

        def new_style?
          !old_style?
        end

        def title_is_summary?
          new_style?
        end

        CLOSED_CASE_PREFIX = 'OFT closed case: '

        def add_summary(doc)
          raise ArgumentError,
                "#{original_url} is not a new-style case" unless new_style?

          self.summary = CLOSED_CASE_PREFIX +
            main_header_text(doc)
        end

        def add_subpage(doc)
          self.summary = CLOSED_CASE_PREFIX +
            main_header_text(doc)

          subpage_name = subpage_name_for(doc)
          markup_sections[subpage_name] = subpage_content_for(doc)

          original_urls << www(original_url_from_meta(doc))
        end

      private
        def main_header_text(doc)
          doc.at_css('.body-copy h1').text.strip
        end

        def www(url)
          if url =~ %r{://www\.}
            url
          else
            url.sub('://', '://www.')
          end
        end

        def subpage_name_for(doc)
          original_url_from_meta(doc) =~ %r{mergers/(.*)$}
          $1
        end

        REMOVE_NODES = <<-XML
          <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
              <xsl:template match="@*|node()">
                  <xsl:copy>
                      <xsl:apply-templates select="@*|node()"/>
                  </xsl:copy>
              </xsl:template>
              <xsl:template match ="div[contains(@class,'body-copy')]//div">
                  <xsl:apply-templates/>
              </xsl:template>
          </xsl:stylesheet>
        XML

        def subpage_content_for(doc)
          doc       = doc.dup
          body_copy = doc.at_css('.body-copy')

          %w(script p.backtotop p.previouspage).each do |selector|
            body_copy.css(selector).remove
          end

          %w(
            //table/@*
            //a/@target
            //a[@name]
            //comment()
          ).each do |superfluous_nodes|
            body_copy.xpath(superfluous_nodes).remove
          end

          body_copy.remove_tna_part_from_hrefs!

          xslt = Nokogiri::XSLT(REMOVE_NODES)
          new_body_copy = xslt.transform(doc).at_css('.body-copy')

          to_kramdown(new_body_copy.inner_html.to_s)
        end

      end
    end
  end
end
