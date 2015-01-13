require 'spec_helper'
require 'cma/schema'

describe CMA::Schema do
  let(:schema) { CMA::Schema.new }
  describe '#outcome_types' do
    subject { schema.outcome_types }

    it { should be_a(Hash) }
    it 'resolves titles to values' do
      expect(
        schema.outcome_types['Markets - phase 1 referral']
      ).to eql('markets-phase-1-referral')
    end
  end

  describe '#market_sector' do
    subject { schema.market_sector }

    it { should be_a(Hash) }
    it 'resolves titles to values' do
      expect(
        schema.market_sector['Healthcare and medical equipment']
      ).to eql('healthcare-and-medical-equipment')
    end
    it 'cares not about case' do
      expect(
        schema.market_sector['healthcare AND mEdical equiPMent']
      ).to eql('healthcare-and-medical-equipment')
    end
    it 'deals with leading and trailing space' do
      expect(
        schema.market_sector['  healthcare AND mEdical equiPMent  ']
      ).to eql('healthcare-and-medical-equipment')
    end
  end
end
