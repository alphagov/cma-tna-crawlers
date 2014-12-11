module CMA
  class Filename
    def self.for(original_url, options = {})
      original_url = URI.parse(original_url) unless original_url.is_a?(URI)

      raise ArgumentError, 'Filename.for can\'t accept a TNA URL' if
        original_url.path =~ %r{https?://}

      result = original_url.path[1..-1].gsub('/', '-').sub(/-$/, '')
      result << '.json' unless options[:no_extension]
      result
    end
  end
end
