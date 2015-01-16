require 'fileutils'
require 'json'
require 'cma/filename'
require 'cma/oft/current/case'
require 'cma/oft/competition/case'
require 'cma/oft/mergers/case'
require 'cma/oft/markets/case'
require 'cma/oft/consumer/case'
require 'cma/cc/case'

module CMA
  class CaseStore
    DEFAULT_LOCATION = '_output'

    def initialize(location = DEFAULT_LOCATION)
      self.location = location
    end

    attr_accessor :location

    def save(_case, filename = nil)
      FileUtils.mkdir_p(location)

      filename ||= begin
        _case.respond_to?(:original_url) or
          raise ArgumentError, 'No filename supplied and content has no original_url'
        Filename.for(_case.original_url)
      end

      File.write(
        File.join(location, filename),
        JSON.pretty_generate(hash_for_pretty_generate(_case))
      )
    end

    def load(filename)
      class_to_load(filename).new.from_json File.read(
      File.join(location, filename))
    end

    def file_exists?(filename)
      File.exists?(File.join(location, filename))
    end

    def find(original_url)
      class_to_load(original_url).new.from_json File.read(full_filename(original_url))
    end

    def exists?(original_url)
      File.exists?(full_filename(original_url))
    end

    MERGER_CASE      = %r{OFTwork[/-]mergers}
    COMPETITION_CASE = %r{OFTwork[/-](oft-current-cases[/-])?competition}
    CONSUMER_CASE    = %r{OFTwork[/-](oft-current-cases[/-])?consumer}
    MARKETS_CASE     = %r{OFTwork[/-](oft-current-cases[/-])?markets?-(work|studies)}
    CC_CASE          = %r{our-work[/-]directory-of-all-inquiries[/-][A-Za-z0-9-]*}

    def class_to_load(original_url_or_filename)
      case original_url_or_filename
      when CONSUMER_CASE    then OFT::Consumer::Case
      when MARKETS_CASE     then OFT::Markets::Case
      when COMPETITION_CASE then OFT::Competition::Case
      when MERGER_CASE      then OFT::Mergers::Case
      when CC_CASE          then CC::Case
      else
        raise ArgumentError, "class_to_load for #{original_url_or_filename} not found"
      end
    end

    private
    def full_filename(original_url)
      File.join(location, Filename.for(original_url))
    end

    ##
    # To get pretty generation, we need a hash.
    # The quick-and-dirty method is to serialize, then reparse the case.
    def hash_for_pretty_generate(_case)
      JSON.parse(_case.to_json)
    rescue JSON::ParserError
      raise ArgumentError, 'Case must be serializable to JSON'
    end
  end
end
