require 'spec_helper'
require 'cma/cc/case_list/page'

module CMA::CC::CaseList
  describe Page do
    describe 'from_html' do
      subject(:page) { Page.from_html(Nokogiri::HTML(File.read("spec/fixtures/cc/#{filename}"))) }

      context 'we are on the page for the letter A' do
        let(:filename) { 'our-work-directory-a.html' }

        it { should be_first_page }

        it 'has links to all the old cases' do
          expect(page.old_case_links.size).to eq(13)
        end

        describe 'the first old case link' do
          subject(:link) { page.old_case_links.first }

          it 'has a title' do
            expect(link.title).to eq(
              'AAH Pharmaceuticals Limited / East Anglian Pharmaceuticals Limited merger inquiry')
          end

          it 'has a TNA link' do
            expect(link.href).to eq(
              'http://webarchive.nationalarchives.gov.uk/20140402141250/'\
              'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/aah-pharmaceuticals-limited-east-anglian-pharmaceuticals-limited')
          end
        end

        it 'has links to all the other letter pages (some are missing)' do
          expect(page.letter_page_links.size).to eq(22)
        end

        describe 'the first letter link' do
          subject(:link) { page.letter_page_links.first }

          it 'has a letter for a title' do
            expect(link.title).to eql('B')
          end

          it 'links to the B page' do
            expect(link.href).to eq(
              'http://webarchive.nationalarchives.gov.uk/20140402141250/'\
              'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries?bytype=atoz&byid=b')
          end
        end

      end

      context 'we are on the page for the letter B' do
        let(:filename) { 'our-work-directory-b.html' }

        it { should_not be_first_page }

        it 'has links to all the old cases' do
          expect(page.old_case_links.size).to eq(14)
        end

        it 'does not link to all the other letter pages' do
          expect(page.letter_page_links.size).to eq(0)
        end
      end
    end
  end
end
