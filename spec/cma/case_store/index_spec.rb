require 'spec_helper'
require 'cma/case_store/index'

describe CMA::CaseStore::Index do
  context 'bad parameters' do
    it 'cannot be created without a location' do
      expect { CMA::CaseStore::Index.new(nil) }.to raise_error(
        ArgumentError, /needs a location/)
    end

    it 'cannot be created without a location that exists' do
      expect { CMA::CaseStore::Index.new('/tmp/does-not-exist') }.to raise_error(
        ArgumentError, /needs an existing location/)
    end
  end

  context 'location provided' do
    let(:location) { 'spec/fixtures/indexable_case_store' }
    let(:index)    { CMA::CaseStore::Index.new(location) }

    it 'remembers where to look' do
      expect(index.location).to eql(location)
    end

    describe '#[]' do
      context 'case with URL does not exist' do
        it 'returns nil' do
          expect(index['http://i.do.not.exist/']).to be_nil
        end
      end

      context 'case with original URL exists' do
        it 'returns the case' do
          expect(index['http://original.url/']).to eql(File.join(location, 'indexable_case.json'))
        end
      end

      context 'case with another url in original_urls exists' do
        it 'returns the case' do
          expect(index['http://some.other.original.url/']).to eql(File.join(location, 'indexable_case.json'))
        end
      end

      context 'case exists with non-www oft version, but we look up by www' do
        it 'returns the case' do
          expect(index['http://www.oft.gov.uk/1']).to eql(File.join(location, 'indexable_case.json'))
        end

        describe '#www' do
          example { expect(index.non_www('http://www.oft.gov.uk/1')).to eql('http://oft.gov.uk/1') }
          example { expect(index.non_www('http://oft.gov.uk/1')).to eql('http://oft.gov.uk/1') }
        end
      end
    end
  end
end
