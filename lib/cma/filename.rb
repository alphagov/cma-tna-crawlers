module CMA
  class Filename
    MAPPINGS = {
      'http://www.oft.gov.uk/OFTwork/markets-work/super-complaints/doorstep-selling' =>
        'OFTwork-oft-current-cases-market-studies-2002-doorstep-selling.json',
      'http://www.oft.gov.uk/OFTwork/markets-work/northern-rock' =>
        'OFTwork-oft-current-cases-market-studies-2008-northern-rock.json'
    }

    def self.for(original_url, options = {})
      MAPPINGS[original_url] || begin
        original_url = URI.parse(original_url) unless original_url.is_a?(URI)
        raise ArgumentError, 'Filename.for can\'t accept a TNA URL' if
          original_url.path =~ %r{https?://}

        result = original_url.path[1..-1].gsub('/', '-').sub(/-$/, '')
        result << '.json' unless options[:no_extension]
        result
      end
    end
  end
end
