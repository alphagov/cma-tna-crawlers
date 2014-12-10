require 'fileutils'
require 'json'
require 'cma/filename'
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

    def find(original_url)
      class_to_load.new.from_json File.read(full_filename(original_url))
    end

    private
    def class_to_load
      CC::Case
    end

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
