require 'fileutils'
require 'active_model'
require 'cma/filename'

module CMA
  class Asset
    include ActiveModel::Serializers::JSON

    attr_accessor :original_url, :content, :content_type, :owner

    def initialize(original_url, owner, content, content_type)
      if original_url =~ Link::TNA_TIMESTAMP
        raise ArgumentError, "Attempted to create Asset with a TNA URL #{original_url}"
      end
      self.original_url = original_url
      self.owner        = owner
      self.content      = content
      self.content_type = content_type
    end

    def serializable_hash(options = {})
      %w(original_url content_type filename).inject({}) do |hash, key|
        hash[key] = self.send(key.to_sym)
        hash
      end.tap do |hash|
        if owner
          hash['filename'] = File.join(owner_base_name, filename)
        end
      end
    end

    def owner_base_name
      Filename.for(owner.original_url, no_extension: true)
    end

    def attributes
      instance_values
    end

    def filename
      uri = original_url.is_a?(URI) ? original_url : URI.parse(original_url)
      @filename ||= File.basename(uri.path)
    end

    def relative_filename
      File.join(owner_base_name, filename)
    end

    def save!(base_location)
      asset_dir = File.join(base_location, owner_base_name)
      FileUtils.mkdir_p(asset_dir)
      File.write(File.join(asset_dir, filename), content)
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      hash == other.hash
    end

    def hash
      original_url.hash
    end
  end
end
