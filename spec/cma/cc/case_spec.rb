require 'spec_helper'
require 'cma/cc/case'

module CMA::CC
  describe Case do
    describe '.from_link' do
      let(:link)  { double('link', href: href, title: title, original_url: original_url) }
      let(:href)  { 'Should not be used' }
      let(:title) { 'A title' }
      let(:original_url) do
        'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/'\
        'alpha-flight-group-limited-lsg-lufthansa-service-holding-ag-merger-inquiry'
      end

      before { expect(link).not_to receive(:href) }

      subject(:_case) { Case.from_link(link) }

      it 'has a title' do
        expect(_case.title).to eql(title)
      end

      it 'is hardwired to closed' do
        expect(_case.case_state).to eql('closed')
      end

      context 'link has a TNA href' do
        let(:href) do
          'http://webarchive.nationalarchives.gov.uk/20140402141250/' + original_url
        end

        it 'uses the original_url from the link' do
          expect(_case.original_url).to eql(original_url)
        end
      end
    end
  end
end
