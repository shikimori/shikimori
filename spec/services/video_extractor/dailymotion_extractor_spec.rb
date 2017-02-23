describe VideoExtractor::DailymotionExtractor, :vcr do
  let(:service) { VideoExtractor::DailymotionExtractor.new url }

  describe '#fetch' do
    subject { service.fetch }

    context 'example 1' do
      let(:url) { 'http://www.dailymotion.com/video/x3xnqk4_mitsuyo-seo-tekusuke-monogatari-%E3%83%86%E3%82%AF%E5%8A%A9%E7%89%A9%E8%AA%9E_shortfilms' }

      its(:hosting) { is_expected.to eq :dailymotion }
      its(:image_url) { is_expected.to eq '//s1-ssl.dmcdn.net/Ua6Tl/526x297-ekd.jpg' }
      its(:player_url) { is_expected.to eq '//www.dailymotion.com/embed/video/x3xnqk4' }
    end

    context 'example 2' do
      let(:url) { 'http://www.dailymotion.com/embed/video/x3xnqk4' }

      its(:hosting) { is_expected.to eq :dailymotion }
      its(:image_url) { is_expected.to eq '//s1-ssl.dmcdn.net/Ua6Tl/526x297-ekd.jpg' }
      its(:player_url) { is_expected.to eq '//www.dailymotion.com/embed/video/x3xnqk4' }
    end
  end
end
