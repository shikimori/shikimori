describe VideoExtractor::RutubeExtractor, :vcr do
  let(:service) { described_class.instance }
  # rubocop:disable Lint/ConstantDefinitionInBlock
  FULL_URL_REGEX = /
    \A
      #{VideoExtractor::RutubeExtractor::URL_REGEX.source}
    \Z
  /xi
  # rubocop:enable Lint/ConstantDefinitionInBlock

  describe '#fetch' do
    subject { service.fetch url }

    context 'valid_url' do
      context 'common case' do
        let(:url) { 'https://rutube.ru/video/d1be34b762250dd49b5be35d805e5f9d/' }

        it do
          is_expected.to have_attributes(
            hosting: :rutube,
            image_url: 'https://pic.rutubelist.ru/video/c1/2e/c12e0ca1ee7133b823c302d0898ee901.jpg?width=300',
            player_url: 'https://rutube.ru/play/embed/d1be34b762250dd49b5be35d805e5f9d',
            normalized_url: 'https://rutube.ru/video/d1be34b762250dd49b5be35d805e5f9d/'
          )
        end
        it { expect(url.match?(FULL_URL_REGEX)).to eq true }
      end
    end
  end
end
