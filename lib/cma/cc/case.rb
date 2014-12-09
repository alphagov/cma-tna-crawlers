module CMA
  module CC
    class Case
      attr_accessor :original_url, :title, :date_of_referral, :statutory_deadline
      def initialize(original_url, title)
        self.original_url  = original_url
        self.title = title
      end

      def case_state
        'closed'
      end

      def self.from_link(link)
        Case.new(link.original_url, link.title)
      end

      def add_case_detail(doc)
        self.date_of_referral   = parse_date_at_xpath(
          doc, [possible_date_position_1(2), possible_date_position_2(2)])
        self.statutory_deadline = parse_date_at_xpath(
          doc, [possible_date_position_1(3), possible_date_position_2(3)])
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
        date_node.text =~ /([0-9]{2}\.[0-9]{2}\.[0-9]{2})/
        Date.strptime($1, '%d.%m.%y') if xpath
      end
    end
  end
end
