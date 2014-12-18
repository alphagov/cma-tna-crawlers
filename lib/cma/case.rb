require 'active_model'
require 'cma/asset'

module CMA
  class Case
    include ActiveModel::Serializers::JSON

    attr_accessor :title, :original_url, :summary, :body

    def assets
      @assets ||= Set.new
    end

    def assets=(array)
      @assets = Set.new(array.map do |v|
                          Asset.new(
                            v['original_url'],
                            self,
                            nil,
                            v['content_type']
                          )
                        end)
    end

    def original_urls
      @original_urls ||= Set.new([original_url])
    end

    def original_urls=(value)
      @original_urls = Set.new(value)
    end

    def attributes
      instance_values
    end

    def attributes=(hash)
      hash.each_pair do |k, v|
        setter = "#{k}="
        self.send(setter, v) if respond_to?(setter)
      end
    end

    def serializable_hash(options={})
      super(options).tap do |hash|
        hash['case_type']  = case_type
        hash['case_state'] = case_state
        hash['original_urls'] = (original_urls << original_url).to_a
      end
    end

    def case_state
      'closed'
    end
  end
end
