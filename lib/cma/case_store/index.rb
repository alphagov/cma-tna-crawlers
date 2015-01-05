require 'json'

module CMA
  class CaseStore
    class Index
      attr_accessor :location

      def initialize(location)
        raise ArgumentError, 'needs a location' if location.nil?
        raise ArgumentError, 'needs an existing location' unless
          Dir.exists?(location)

        self.location = location
      end

      def [](url)
        hash[url] || hash[non_www(url)]
      end

      def hash
        @_hash ||= index(location)
      end

      def non_www(url)
        if url !~ %r{://www\.}
          url
        else
          url.sub('://www.', '://')
        end
      end

      private

      def index(location)
        Dir[File.join(location, '*.json')].inject({}) do |index_hash, json_filename|
          JSON.parse(File.read(json_filename)).tap do |json_hash|
            next unless original_urls = json_hash['original_urls']
            original_urls.each do |original_url|
              index_hash[original_url] = json_filename
            end
          end
          index_hash
        end
      end
    end
  end
end
