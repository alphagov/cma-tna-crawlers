require 'spec_helper'
require 'cma/cc/body_generator'
require 'cma/case_store'

describe CMA::CC::BodyGenerator do

  describe 'creating a new one' do
    let(:location)      { 'spec/fixtures/cc' }
    let(:case_store)    { CMA::CaseStore.new(location) }
    let(:case_filename) { 'our-work-directory-of-all-inquiries-aeg-wembley-arena.json' }
    let(:_case)         { case_store.load(case_filename) }

    subject(:body_generator) { CMA::CC::BodyGenerator.new(_case) }

    describe '#generate!' do
      before do
        body_generator.generate!
      end

      subject(:case_body) { _case.body }

      it 'begins with an h2 Phase 2 header' do
        expect(case_body).to match /^## Phase 2/
      end

      it 'uses the date of referral' do
        expect(case_body).to have_content('Date of referral:  22/03/2013').under('## Phase 2')
      end
      it 'uses the statutory deadline' do
        expect(case_body).to have_content('Statutory deadline:  05/09/2013').under('## Phase 2')
      end

      it 'puts the CC headers at h3' do
        expect(case_body).to include('### Core documents')
      end
      it 'excludes the useless analysis page' do
        expect(case_body).to_not include("Analysis\n\n* [Working\n  papers]")
      end

      describe 'included useful evidence content' do
        it { should include '### Summaries of hearings held with third parties' }
        it { should include '### Initial submissions' }
      end

      describe 'the news section' do
        it { should include '### News releases' }
        it { should include '[CC to investigate AEG/Wembley Arena' }
      end
    end
  end

end
