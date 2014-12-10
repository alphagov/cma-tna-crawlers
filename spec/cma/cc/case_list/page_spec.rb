require 'spec_helper'
require 'cma/case_store'
require 'cma/cc/case_list/page'

module CMA::CC::CaseList
  describe Page do
    describe 'from_html' do
      subject(:page) { Page.from_html(Nokogiri::HTML(File.read("spec/fixtures/cc/#{filename}"))) }

      context 'we are on the page for the letter A' do
        let(:filename) { 'our-work-directory-a.html' }

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

        describe 'cases' do
          it 'has one CMA case per link' do
            expect(page.cases.size).to eql(13)
            expect(page.cases.all? { |c| expect(c).to be_a(CMA::CC::Case) }).to eql(true)
          end
        end

        describe '#save_to' do
          let(:case_store) { instance_spy CMA::CaseStore }

          it 'saves all the cases to the case store' do
            page.save_to(case_store)

            page.cases.each do |_case|
              expect(case_store).to have_received(:save).with(_case)
            end
          end
        end
      end
    end
  end
end
