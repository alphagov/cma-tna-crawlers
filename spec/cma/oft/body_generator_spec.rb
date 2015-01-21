require 'spec_helper'
require 'cma/oft/body_generator'
require 'cma/case_store'

describe CMA::OFT::BodyGenerator do

  describe 'creating a new one' do
    let(:location)      { 'spec/fixtures/oft' }
    let(:case_store)    { CMA::CaseStore.new(location) }
    let(:_case)         { case_store.load(case_filename) }

    subject(:body_generator) { CMA::OFT::BodyGenerator.new(_case) }

    describe '#generate!' do
      subject(:body) { body_generator.generate! }

      context 'A mergers case' do
        let(:case_filename) { 'OFTwork-mergers-Mergers_Cases-2008-coop-somerfield.json' }
        let(:title) { /Anticipated acquisition by Co-operative Group Limited of Somerfield Limited/ }

        it 'has two h2s with the same title' do
          expect(body).to match(/#{title}.*#{title}/m)
        end
      end

      context 'A markets case' do
        let(:case_filename) { 'OFTwork-markets-work-references-store-cards1.json' }

        let(:core_documents_snippet) { 'OFT carried out an informal' }
        let(:extra_detail_snippet)   { 'Store cards terms of reference' }
        let(:extra_detail_snippet2)  { 'Store cards varied terms of reference' }

        it 'has parts from the core documents' do
          expect(body).to include(core_documents_snippet)
        end
        it 'has parts from the terms of reference' do
          expect(body).to include(extra_detail_snippet)
        end
        it 'has parts from the varied terms of reference' do
          expect(body).to include(extra_detail_snippet2)
        end

        it 'has all these parts in order' do
          expect(body.index(core_documents_snippet)).to be < body.index(extra_detail_snippet)
          expect(body.index(extra_detail_snippet)).to be < body.index(extra_detail_snippet2)
        end
      end
    end
  end

end
