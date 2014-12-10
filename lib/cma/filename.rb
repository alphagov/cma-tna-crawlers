module CMA
  class Filename
    def self.for(original_url)
      original_url = URI.parse(original_url) unless original_url.is_a?(URI)

      raise ArgumentError, 'Filename.for can\'t accept a TNA URL' if
        original_url.path =~ %r{https?://}

      original_url.path[1..-1].gsub('/', '-').sub(/-$/, '') + '.json'
    end
  end
end
