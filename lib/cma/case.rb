require 'active_model'

module CMA
  class Case
    include ActiveModel::Serializers::JSON

    attr_accessor :title, :original_url

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
      end
    end

    def case_state
      'closed'
    end
  end
end
