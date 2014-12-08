module CMA
  class Link
    TNA_TIMESTAMP = %r{https?://webarchive\.nationalarchives\.gov\.uk/[0-9]{14}/}

    attr_reader :title
    def initialize(uri, title = nil)
      @uri = uri
      @title = title
    end

    def href
      @uri.to_s
    end

    def original_url
      @uri.to_s.sub(TNA_TIMESTAMP, '')
    end

    def self.from_uri(uri, title = nil)
      raise ArgumentError, 'uri must be a URI' unless uri.is_a?(URI)
      raise ArgumentError, 'URI must be absolute' unless uri.absolute?

      Link.new(uri, title)
    end
  end
end
