describe AnimeSpiritImporter, vcr: { cassette_name: 'anime_spirit_parser' } do
  let(:importer) { AnimeSpiritImporter.new }

  describe 'import' do
    subject(:import) { importer.import pages: pages, ids: ids, last_episodes: last_episodes }
    let!(:anime) { create :anime, name: 'Burn Up!' }
    let(:link) { 'http://www.animespirit.ru/anime/141-burn-up-razgon.html' }
    let(:last_episodes) { false }
    let(:pages) { [0] }
    let(:ids) { [] }
    before { allow_any_instance_of(AnimeSpiritParser).to receive(:fetch_page_links).and_return [link] }

    describe 'video' do
      let(:videos) { AnimeVideo.where anime_id: anime.id }

      context 'no_videos' do
        it { expect{subject}.to change(videos, :count).by 4 }
      end

      context 'with_videos' do
        let!(:video) { create :anime_video, anime_id: anime.id, episode: 1, url: 'http://video.sibnet.ru/shell.swf?videoid=506340', source: 'http://www.animespirit.ru/anime/141-burn-up-razgon.html' }
        it { expect{subject}.to change(videos, :count).by 3 }
      end
    end
  end
end
