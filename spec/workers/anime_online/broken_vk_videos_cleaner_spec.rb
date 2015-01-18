describe AnimeOnline::BrokenVkVideosCleaner, vcr: { cassette_name: 'broken_vk_videos_cleaner' } do
  let(:worker) { AnimeOnline::BrokenVkVideosCleaner.new }
  let(:anime) { create :anime }
  let!(:video) { }
  let!(:report) { }

  describe '#perform' do
    before { worker.perform }

    context 'valid video' do
      let!(:video) { create :anime_video, anime: anime, url: 'http://vk.com/video_ext.php?oid=-888489&id=139696321&hash=3d179e1451dffacc' }
      it { expect(video.reload).to be_working }
    end

    context 'no export video' do
      let!(:video) { create :anime_video, anime: anime, url: 'http://vk.com/video_ext.php?oid=-23314707&id=160661445&hash=5bc587ab61aace17&hd=3' }
      it { expect(video.reload).to be_broken }
    end

    context 'broken video' do
      let!(:video) { create :anime_video, anime: anime, url: 'http://vk.com/video_ext.php?oid=-18070179&id=159913977&hash=c49d82b08c9fcc3e&hd=3' }
      it { expect(video.reload).to be_broken }

      describe 'pending report' do
        let!(:report) { create :anime_video_report, :with_user, anime_video: video, kind: :broken }
        it { expect(report.reload).to be_accepted }
      end
    end
  end
end
