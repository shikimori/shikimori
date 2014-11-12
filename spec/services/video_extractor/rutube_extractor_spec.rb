describe VideoExtractor::RutubeExtractor do
  let(:service) { VideoExtractor::RutubeExtractor.new(url) }

  describe '#fetch' do
    let(:video_data) { service.fetch }
    before { VCR.use_cassette(:rutube_video) { video_data } }

    context 'valid' do
      let(:url) { 'http://rutube.ru/video/5939d6aea686bc83a86c86d24f40435e/' }
      it { expect(video_data.hosting).to eq :rutube }
      it { expect(video_data.image_url).to be_nil }
      it { expect(video_data.player_url).to eq 'http://rutube.ru/play/embed/7300160' }
    end
  end
end

