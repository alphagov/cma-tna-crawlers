require 'spec_helper'
require 'nokogiri'
require 'cma/oft/mergers/case'

module CMA::OFT
  describe Case do
    let(:_case) { Mergers::Case.create('http://example.com', 'title') }

    describe '#sanitised_body_content' do
      let(:doc)     { Nokogiri::HTML(File.read('spec/fixtures/oft/accraply-fntq-no-pdf.html')) }
      let(:options) { { } }

      subject(:content) { _case.sanitised_body_content(doc, options) }

      context 'no options' do
        it 'transforms to markdown' do
          expect(content).to include('#  Completed acquisition')
        end
      end
      context 'header_offset' do
        let(:options) { { header_offset: 1 }}
        it 'transforms the headers' do
          expect(content).to include('##  Completed acquisition')
        end
      end
    end
  end
end
