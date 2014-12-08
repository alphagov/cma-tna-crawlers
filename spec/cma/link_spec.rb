require 'spec_helper'
require 'cma/link'

module CMA
  describe Link do
    describe '.from_uri' do
      subject(:link) { Link.from_uri(uri) }

      context 'the URI is not a URI' do
        let(:uri) { '/accidentally-a-string' }

        it 'fails' do
          expect { subject }.to raise_error(ArgumentError, /uri must be a URI/)
        end
      end

      context 'the URI is a URI' do
        let(:uri) { URI(href) }

        context 'the href is relative' do
          let(:href) { '/just-a-path' }

          it 'fails' do
            expect { link }.to raise_error(ArgumentError, /URI must be absolute/)
          end
        end

        context 'the href is from TNA' do
          let(:href) {
            'http://webarchive.nationalarchives.gov.uk/20140402141250/'\
            'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/cable-and-wireless-ofcom'
          }

          it 'retains the href' do
            expect(link.href).to eql(href)
          end

          describe '#original_url' do
            it 'gives us the original URL' do
              expect(link.original_url).to eql(
                'http://www.competition-commission.org.uk/our-work/directory-of-all-inquiries/cable-and-wireless-ofcom'
              )
            end
          end
        end
      end

      context 'there is a title' do
        it 'stores the title' do
          expect(
            Link.from_uri(URI('http://example.com/1'), 'Example 1').title
          ).to eql('Example 1')
        end
      end
    end
  end
end
