require 'spec_helper'
require 'cma/case_store'
require 'cma/cc/case'
require 'cma/oft/case'

module CMA
  describe CaseStore do
    describe '#location' do
      context 'with no location' do
        it 'defaults to _output' do
          expect(CaseStore.new.location).to eql('_output')
        end
      end

      context 'with a given location' do
        it 'points to that location' do
          expect(CaseStore.new('spec/fixtures/store').location).to eql('spec/fixtures/store')
        end
      end
    end

    describe '#save' do
      let(:case_store) { CaseStore.new('spec/fixtures/store') }

      before { FileUtils.rmtree(case_store.location) }
      after  { FileUtils.rmtree(case_store.location) }

      context 'when the object to save is not serializable to JSON' do
        it 'fails but leaves the dir' do
          expect { case_store.save(1, 'filename.json') }.
            to raise_error(ArgumentError, /Case must be serializable to JSON/)
          expect(Dir).to exist(case_store.location)
        end
      end

      context 'when the object to save is serializable to JSON' do
        let(:case_content) { {'a' => 'b'} }

        context 'and a filename is supplied' do
          before { case_store.save(case_content, 'ab-hash.json') }

          it 'saves the object to the location' do
            expect(File).to exist('spec/fixtures/store/ab-hash.json')
          end

          it 'saves the object as JSON' do
            reparsed_json = JSON.parse(File.read('spec/fixtures/store/ab-hash.json'))
            expect(reparsed_json).to eql(case_content)
          end

        end

        context 'no filename is supplied and CaseStore cannot make one' do
          it 'fails' do
            expect {
              case_store.save(case_content)
            }.to raise_error(ArgumentError, 'No filename supplied and content has no original_url')
          end
        end

        context 'no filename is supplied but CaseStore can make one from original_url' do
          let(:original_url) { 'http://example.com/somewhere/nice' }

          before do
            expect(Filename).to receive(:for).with(original_url).and_return('filename.json')
            expect(case_content).to receive(:original_url).and_return(original_url)
          end

          it 'saves' do
            case_store.save(case_content)
            expect(File).to exist('spec/fixtures/store/filename.json')
          end
        end

      end
    end

    describe '`.find`ing a case we just saved by URL' do
      let(:case_store) { CaseStore.new('spec/fixtures/store') }

      before { case_store.save(case_to_save) }
      after  { FileUtils.rmtree(case_store.location) }

      let(:title) { 'test_title' }
      let!(:case_to_save) do
        klass.create(original_url, title)
      end

      subject(:_case) { case_store.find(original_url) }

      context 'the case is a CC case' do
        let(:klass) { CC::Case }
        let(:original_url) do
          'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/arcelor-sa-corus-uk-limited'
        end

        it 'hydrates the right class' do
          expect(_case).to be_a(CC::Case)
        end

        describe 'the case' do
          example { expect(_case.title).to eql(title) }
          example { expect(_case.original_url).to eql(original_url) }
        end
      end

      context 'the case is an OFT case' do
        let(:klass) { OFT::Case }
        let(:original_url) do
          'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2011/access-control-alarm-systems'
        end

        it 'hydrates the right class' do
          expect(_case).to be_an(OFT::Case)
        end

        describe 'the case' do
          example { expect(_case.title).to eql(title) }
          example { expect(_case.original_url).to eql(original_url) }
        end
      end

    end
  end
end
