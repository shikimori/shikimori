describe VideoExtractor do
  subject(:fetch) { VideoExtractor.fetch url }

  describe 'fetch' do
    context 'youtube' do
      let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }
      it { should be_kind_of VideoData }
      its(:hosting) { should be :youtube }
    end

    context 'vk', vcr: { cassette_name: 'vk_video' } do
      let(:url) { 'http://vk.com/video98023184_165811692' }
      it { should be_kind_of VideoData }
      its(:hosting) { should be :vk }
    end

    context 'unmatched' do
      let(:url) { 'http://ya.ru' }
      it { should be_nil }
    end
  end
end
