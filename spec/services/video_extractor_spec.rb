describe VideoExtractor do
  subject(:fetch) { VideoExtractor.fetch url }

  describe 'fetch' do
    context 'youtube' do
      let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }
      it { is_expected.to be_kind_of VideoData }
      its(:hosting) { is_expected.to be :youtube }
    end

    context 'vk', vcr: { cassette_name: 'video_extractor' } do
      let(:url) { 'http://vk.com/video98023184_165811692' }
      it { is_expected.to be_kind_of VideoData }
      its(:hosting) { is_expected.to be :vk }
    end

    context 'unmatched' do
      let(:url) { 'http://ya.ru' }
      it { is_expected.to be_nil }
    end
  end
end
