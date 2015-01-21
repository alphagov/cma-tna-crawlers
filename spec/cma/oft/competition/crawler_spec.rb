require 'spec_helper'
require 'cma/oft/competition/crawler'

module CMA::OFT::Competition
  describe 'Case detail' do
    it 'matches Reckitt Benckiser (cases at /decisions/)' do
      expect(Crawler::CASE_DETAIL).to match(
        'http://oft.gov.uk/OFTwork/competition-act-and-cartels/ca98/decisions/reckitt-benckiser')
    end
  end
end
