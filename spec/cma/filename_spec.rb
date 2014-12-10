require 'spec_helper'
require 'cma/filename'

module CMA
  describe Filename do
    describe '.for' do
      context 'original_url is a String with a path-only URI' do
        it 'makes a filename from the path' do
          expect(Filename.for('/somewhere/nice')).to eql('somewhere-nice')
        end
        it 'makes a filename from the path with a / at the end' do
          expect(Filename.for('/somewhere/nice/')).to eql('somewhere-nice')
        end
      end

      context 'original_url is a String with an absolute URI' do
        it 'makes a filename' do
          expect(Filename.for('http://example.com/somewhere/nice')).to eql('somewhere-nice')
        end
      end

      context 'accidentally received a TNA URL' do
        it 'stops us from shooting ourselves in the foot' do
          expect {
            Filename.for('http://webarchive.nationalarchives.gov.uk/20140402141250/http://www.competition-commission.org.uk/our-work')
          }.to raise_error(ArgumentError, /TNA URL/)
        end
      end
    end
  end
end
