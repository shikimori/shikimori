describe AnimeOnline::AnimeVideoDuplicates do
  let(:query) { AnimeOnline::AnimeVideoDuplicates.new url }

  let(:anime_video_1) { create :anime_video, url: url }
  let(:anime_video_2) { create :anime_video, url: url + 'z' }
  let(:link) { 'video.sibnet.ru/shell.php?videoid=1186077' }

  subject! { query.call }

  context 'not matched url' do
    let(:url) { "http://#{link}zzz" }
    it { is_expected.to eq [] }
  end

  context 'matched url' do
    context 'http' do
      let(:url) { "http://#{link}" }
      it { is_expected.to eq [anime_video_1] }
    end

    context 'https' do
      let(:url) { "https://#{link}" }
      it { is_expected.to eq [anime_video_1] }
    end
  end
end
