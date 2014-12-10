require 'spec_helper'
require 'cma/cc/case'
require 'nokogiri'

module CMA::CC
  describe Case do
    let(:link)  { double('link', href: href, title: title, original_url: original_url) }
    let(:href)  { 'Should not be used' }
    let(:title) { 'A title' }
    let(:original_url) do
      'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/'\
        'alpha-flight-group-limited-lsg-lufthansa-service-holding-ag-merger-inquiry'
    end

    describe '.from_link' do
      before { expect(link).not_to receive(:href) }

      subject(:_case) { Case.from_link(link) }

      it 'has a title' do
        expect(_case.title).to eql(title)
      end

      it 'cannot work out the case_type from this title' do
        expect(_case.case_type).to eql('unknown')
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

        describe 'serialization' do
          it 'serializes to JSON' do
            expect(JSON.parse(_case.to_json)).to eql(
               {
                 'original_url' => 'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/'\
                                   'alpha-flight-group-limited-lsg-lufthansa-service-holding-ag-merger-inquiry',
                 'title' => 'A title',
                 'case_state' => 'closed',
                 'case_type' => 'unknown'
               }
             )
          end
        end
      end

      context 'case_type is a mergers inquiry' do
        let(:title) { 'Alpha Flight Group Limited / LSG Lufthansa Service Holding AG merger inquiry' }

        example { expect(_case.case_type).to eql('mergers') }
      end

      context 'case_type is a mergers inquiry' do
        let(:title) { 'Greater Western Passenger Rail Franchise merger inquiries' }

        example { expect(_case.case_type).to eql('mergers') }
      end

      context 'case_type is a markets investigation' do
        let(:title) { 'Classified Directory Advertising Services market investigation' }

        example { expect(_case.case_type).to eql('markets') }
      end
    end

    describe 'Adding more detail' do
      let(:doc) { Nokogiri::HTML(File.read('spec/fixtures/cc/archived-arcelor-case.html')) }

      subject(:_case) { Case.new(original_url, title) }

      describe '#add_case_detail' do
        before { _case.add_case_detail(doc) }

        it 'parses the date of referral' do
          expect(_case.date_of_referral).to eql(Date.new(2004, 9, 10))
        end
        it 'parses the statutory deadline' do
          expect(_case.statutory_deadline).to eql(Date.new(2005, 2, 24))
        end
      end

      describe '#add_markdown_detail' do
        let(:subpage_doc) { Nokogiri::HTML(File.read('spec/fixtures/cc/archived-arcelor-final-report.html')) }

        before do
          _case.add_markdown_detail(subpage_doc, 'provisional_final_report')
        end

        it 'added the section' do
          expect(_case.markup_sections['provisional_final_report']).not_to be_blank
        end

        describe 'the section' do
          subject(:section_markdown) { _case.markup_sections['provisional_final_report'] }

          it { should include('## Final report and Appendices &amp; Glossary') }
          it 'has nothing above the title (this is repeated and parsed elsewhere)' do
            expect(section_markdown).not_to include('Statutory deadline')
            expect(section_markdown).not_to include('# Arcelor SA')
          end
          it 'leaves no TNA parts of URLs' do
            expect(section_markdown).not_to include('http://webarchive.nationalarchives.gov.uk/')
          end
          it 'transforms TNA URLs to their original form' do
            expect(section_markdown).to include(
              'http://www.competition-commission.org.uk/'\
              'assets/competitioncommission/docs/pdf/non-inquiry/rep_pub/reports/2005/fulltext/498.pdf'
            )
          end
        end
      end
    end
  end
end
