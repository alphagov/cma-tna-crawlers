module CMA
  module CC
    class Case
      attr_accessor :original_url, :title
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
    end
  end
end
