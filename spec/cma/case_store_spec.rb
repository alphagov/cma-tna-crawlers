require 'spec_helper'
require 'cma/case_store'
require 'cma/cc/case'
require 'cma/oft/current/case'

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

    describe '#exists? / #file_exists?' do
      let(:case_store) { CaseStore.new('spec/fixtures/store') }

      context 'the case does not exist' do
        specify 'exists? returns false' do
          expect(case_store.exists?('http://no.chance/etc/etc')).to eql(false)
        end
        specify 'file_exists? returns false' do
          expect(case_store.exists?('etc-etc')).to eql(false)
        end
      end
      context 'the case exists' do
        let(:original_url) {
          'http://oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2011/access-control-alarm-systems'
        }
        let(:case_to_save) { OFT::Case.create(original_url, 'Title') }

        before do
          case_store.save(case_to_save)
        end

        specify 'exists? returns true' do
          expect(case_store.exists?(original_url)).to eql(true)
        end
        specify 'file_exists? returns true' do
          expect(case_store.file_exists?(
            'OFTwork-oft-current-cases-competition-case-list-2011-access-control-alarm-systems.json'
          )).to eql(true)
        end
      end
    end

    describe 'what to load via .load_class' do
      let(:case_store) { CaseStore.new('spec/fixtures/store') }

      it 'loads a Mergers case for a merger URL' do
        expect(case_store.class_to_load(
          'http://example.com/OFTwork/mergers/Mergers_Cases/2013/Alliance.json')
        ).to eql(CMA::OFT::Mergers::Case)
      end
      it 'loads a Mergers case for a merger filename' do
        expect(case_store.class_to_load(
          'OFTwork-mergers-Mergers_Cases-2013-Alliance.json')
        ).to eql(CMA::OFT::Mergers::Case)
      end
      it 'loads a Competition case for a competition URL' do
        expect(case_store.class_to_load(
          'http://example.com/OFTwork/oft-current-cases/competition-case-list-2005/interchage-fees-mastercard.json')
        ).to eql(CMA::OFT::Competition::Case)
      end
      it 'loads a Competition case for a competition filename' do
        expect(case_store.class_to_load(
          'OFTwork-oft-current-cases-competition-case-list-2005-interchage-fees-mastercard.json')
        ).to eql(CMA::OFT::Competition::Case)
      end
      it 'loads a Consumer case for a consumer URL' do
        expect(case_store.class_to_load(
          'http://example.com/OFTwork/oft-current-cases/consumer-case-list-2012/furniture-carpets.json')
        ).to eql(CMA::OFT::Consumer::Case)
      end
      it 'loads a Consumer case for a consumer filename' do
        expect(case_store.class_to_load(
          'OFTwork-oft-current-cases-consumer-case-list-2012-furniture-carpets.json')
        ).to eql(CMA::OFT::Consumer::Case)
      end
      it 'loads a Markets case for a markets URL' do
        expect(case_store.class_to_load(
          'http://example.com/OFTwork/oft-current-cases/markets-work-2013/higher-education-cfi.json')
        ).to eql(CMA::OFT::Markets::Case)
      end
      it 'loads a Markets case for a markets URL' do
        expect(case_store.class_to_load(
          'http://example.com/OFTwork/oft-current-cases/market-studies-2012/personal-current-accounts.json')
        ).to eql(CMA::OFT::Markets::Case)
      end
      it 'loads a Markets case for a markets URL' do
        expect(case_store.class_to_load(
          'OFTwork-oft-current-cases-market-studies-2012-personal-current-accounts.json')
        ).to eql(CMA::OFT::Markets::Case)
      end
      it 'loads a CC case for a CC URL' do
        expect(case_store.class_to_load(
          'http://example.com/our-work/directory-of-all-inquiries/aggregates-cement-ready-mix-concrete.json')
        ).to eql(CMA::CC::Case)
      end
      it 'loads a CC case for a CC filename' do
        expect(case_store.class_to_load(
          'our-work-directory-of-all-inquiries-aggregates-cement-ready-mix-concrete.json')
        ).to eql(CMA::CC::Case)
      end
    end

    describe 'retrieving a case we just saved by URL' do
      let(:case_store) { CaseStore.new('spec/fixtures/store') }

      before { case_store.save(case_to_save) }
      after  { FileUtils.rmtree(case_store.location) }

      let(:title) { 'test_title' }
      let!(:case_to_save) do
        klass.create(original_url, title).tap do |_case|
          _case.original_urls << 'http://example.com/2'
        end
      end

      describe '#find' do
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
            example { expect(_case.original_urls.size).to eql(2) }
          end
        end

        context 'the case is an OFT "current cases" closed case' do
          let(:klass) { OFT::Current::Case }
          let(:original_url) do
            'http://www.oft.gov.uk/OFTwork/oft-current-cases/competition-case-list-2011/access-control-alarm-systems'
          end

          it 'hydrates the right class' do
            expect(_case).to be_an(OFT::Current::Case)
          end

          describe 'the case' do
            example { expect(_case.title).to eql(title) }
            example { expect(_case.original_url).to eql(original_url) }
            example { expect(_case.original_urls.size).to eql(2) }
          end
        end
      end

      describe '#load' do
        let(:klass) { CC::Case }
        let(:original_url) do
          'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/arcelor-sa-corus-uk-limited'
        end

        subject(:_case) do
          case_store.load('our-work-directory-of-all-inquiries-arcelor-sa-corus-uk-limited.json')
        end

        describe 'the case' do
          example { expect(_case.title).to eql(title) }
          example { expect(_case.original_url).to eql(original_url) }
          example { expect(_case.original_urls.size).to eql(2) }
        end
      end

    end
  end
end
