require 'cma/case'
require 'cma/markup_helpers'
require 'kramdown'
require 'kramdown/converter/kramdown_patched'

module CMA
  module OFT
    class Case < CMA::Case
      def case_type
        'unknown'
      end

      def to_kramdown(content)
        Kramdown::Document.new(content, input: 'html').to_kramdown.gsub(/\{:.+?}/m, '')
      end

      # <meta name="DC.identifier" scheme="DCTERMS.URI"
      #   content="http://oft.gov.uk/OFTwork/markets-work/taxis" />
      def original_url_from_meta(doc)
        doc.at_xpath(
          '//head/meta[@name="DC.identifier"][@scheme="DCTERMS.URI"]/@content'
        ).to_s.sub(%r{://oft\.}, '://www.oft.')
      end

      def www(url)
        if url =~ %r{://www\.}
          url
        else
          url.sub('://', '://www.')
        end
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

      def sanitised_body_content(doc)
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

      def self.create(original_url, title)
        self.new.tap do |c|
          c.title = title
          c.original_url = original_url
        end
      end
    end
  end
end
