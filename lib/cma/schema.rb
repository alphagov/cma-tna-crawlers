require 'json'

module CMA
  class Schema
    def outcome_types
      @_outcome_types ||= get_allowed_value_hash('outcome_type')
    end

    def market_sector
      @_market_sector ||= get_allowed_value_hash('market_sector')
    end

    def get_allowed_value_hash(key)
      keyed_section = json_hash['facets'].find { |hash| hash['key'] == key }

      keyed_section['allowed_values'].inject({}) do |output_hash, label_value|
        label, value = label_value['label'], label_value['value']

        output_hash[label] = value
        output_hash
      end
    end

    def self.instance
      @@instance ||= CMA::Schema.new
    end
  private
    def json_hash
      @_json_hash ||= JSON.parse(File.read('schema/cma-cases.json'))
    end
  end
end
