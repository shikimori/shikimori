describe VideoExtractor::RutubeExtractor, :vcr do
  let(:service) { described_class.instance }

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
            normalized_url: url
          )
        end
      end

      context 'shorts' do
        let(:url) { 'https://rutube.ru/shorts/c9c281676b7420be84f19b808f1e4349/' }

        it do
          is_expected.to have_attributes(
            hosting: :rutube_shorts,
            image_url: 'https://pic.rutubelist.ru/video/94/ac/94ac051bc0c7d52ce754cebcd413bc6d.jpg?width=300',
            player_url: 'https://rutube.ru/play/embed/c9c281676b7420be84f19b808f1e4349',
            normalized_url: url
          )
        end
      end
    end
  end
end
