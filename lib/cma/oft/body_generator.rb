require 'kramdown'

module CMA
  module OFT
    class BodyGenerator
      attr_accessor :_case

      def initialize(_case)
        self._case = _case
      end

      def generate!
        _case.body = ''.tap do |body|
          _case.markup_sections.each_pair do |name, section_body|
            Kramdown::Document.new(
              section_body, header_offset: 1
            ).tap do |tree|
              body << tree.to_kramdown
            end
          end
        end
      end
    end
  end
end
