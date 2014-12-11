require 'spec_helper'
require 'cma/cc/case'
require 'cma/asset'
require 'json'

describe CMA::Asset do
  describe 'creating from a big chunk o\'bytes' do
    after { FileUtils.rmtree('spec/fixtures/store') }

    Given(:_case)        { instance_double(CMA::CC::Case, original_url: 'http://some.case/case-base-name') }
    Given(:original_url) { 'http://some.asset/APS-letter.pdf' }
    Given(:owner)        { _case }
    Given(:content)      { 'Not really the contents of a PDF' }
    Given(:content_type) { 'application/pdf' }

    When(:asset) { CMA::Asset.new(original_url, _case, content, content_type) }

    Then { asset.content           == 'Not really the contents of a PDF' }
    Then { asset.content_type      == 'application/pdf' }
    Then { asset.owner             == owner }
    Then { asset.filename          == 'APS-letter.pdf' }
    Then { asset.relative_filename == 'case-base-name/APS-letter.pdf' }

    it 'serializes its details as JSON' do
      expect(JSON.parse(asset.to_json)).to eql({
        'original_url' => 'http://some.asset/APS-letter.pdf',
        'content_type' => 'application/pdf',
        'filename'     => 'case-base-name/APS-letter.pdf'
      })
    end

    context 'We mistakenly feed Asset a TNA URL' do
      Given(:original_url) do
        'http://webarchive.nationalarchives.gov.uk/20140402141250/'\
        'http://www.competition-commission.org.uk/assets/'\
        'competitioncommission/docs/pdf/non-inquiry/rep_pub/reports/2004/fulltext/487ad.pdf'
      end

      Then { asset == Failure(ArgumentError, /TNA URL/) }
    end

    describe 'equality' do
      let(:other_with_same_url) { CMA::Asset.new('http://some.asset/APS-letter.pdf', nil, nil, nil) }
      let(:other_with_diff_url) { CMA::Asset.new('http://some.asset/APS-letter2.pdf', nil, nil, nil) }

      it 'is equal to the first with the same URL' do
        expect(asset).to eql(other_with_same_url)
        expect(asset == other_with_same_url).to eql(true)
      end
      it 'is different to the second with a different URL' do
        expect(asset).not_to eql(other_with_diff_url)
        expect(asset == other_with_diff_url).to eql(false)
      end
      describe 'works in a Set' do
        subject { Set.new([asset, other_with_same_url, other_with_diff_url]).to_a }
        it      { should match_array([asset, other_with_diff_url]) }
      end
    end

    describe 'saving' do
      before { asset.save!('spec/fixtures/store') }

      it "saves the file in a folder named the same as its owning case's basename" do
        filename = File.join('spec/fixtures/store', asset.relative_filename)
        expect(File).to exist(filename)
      end
    end

    context 'when the original_url is a URI' do
      let(:original_url) { URI('http://some.asset/APS-letter.pdf') }
      it 'calculates a filename correctly ' do
        expect(asset.filename).to eql('APS-letter.pdf')
      end
    end
  end
end
