describe VideoExtractor::OkExtractor, :vcr do
  let(:service) { described_class.instance }

  describe '#fetch' do
    subject { service.fetch url }

    context '/live/' do
      let(:url) { 'https://ok.ru/live/815923404420' }

      its(:hosting) { is_expected.to eq :ok }
      its(:image_url) { is_expected.to eq '//pimg.mycdn.me/getImage?disableStub=true&type=VIDEO_S_720&url=http%3A%2F%2Fvdp.mycdn.me%2FgetImage%3Fid%3D381639461508%26idx%3D0%26thumbType%3D37%26f%3D1&signatureToken=TZAM-cHk_kQis5JdW_-ncg' }
      its(:player_url) { is_expected.to eq '//ok.ru/videoembed/815923404420' }
    end

    context '/videoembed/' do
      let(:url) { 'https://ok.ru/videoembed/815923404420' }

      its(:hosting) { is_expected.to eq :ok }
      its(:image_url) { is_expected.to eq '//pimg.mycdn.me/getImage?disableStub=true&type=VIDEO_S_720&url=http%3A%2F%2Fvdp.mycdn.me%2FgetImage%3Fid%3D381639461508%26idx%3D0%26thumbType%3D37%26f%3D1&signatureToken=TZAM-cHk_kQis5JdW_-ncg' }
      its(:player_url) { is_expected.to eq '//ok.ru/videoembed/815923404420' }
    end

    context '/video/' do
      let(:url) { 'https://ok.ru/video/815923404420' }

      its(:hosting) { is_expected.to eq :ok }
      its(:image_url) { is_expected.to eq '//pimg.mycdn.me/getImage?disableStub=true&type=VIDEO_S_720&url=http%3A%2F%2Fvdp.mycdn.me%2FgetImage%3Fid%3D381639461508%26idx%3D0%26thumbType%3D37%26f%3D1&signatureToken=TZAM-cHk_kQis5JdW_-ncg' }
      its(:player_url) { is_expected.to eq '//ok.ru/videoembed/815923404420' }
    end
  end
end
