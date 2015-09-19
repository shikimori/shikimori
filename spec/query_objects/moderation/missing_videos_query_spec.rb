describe Moderation::MissingVideosQuery do
  let(:query) { Moderation::MissingVideosQuery.new kind }

  describe '#fetch' do
    let!(:anime) { create :anime, :released, episodes: 2, score: 8 }

    context 'all' do
      let(:kind) { 'all' }
      let!(:anime_video) { create :anime_video, :subtitles, anime: anime, episode: 1 }

      context 'no missing videos' do
        let!(:anime_video_2) { create :anime_video, :subtitles, anime: anime, episode: 2 }
        it { expect(query.fetch).to be_empty }
      end

      context 'missing video' do
        it { expect(query.fetch).to have(1).item }
      end

      context 'anons' do
        let!(:anime) { create :anime, :anons, episodes: 2 }
        it { expect(query.fetch).to be_empty }
      end

      context 'no episodes at all' do
        let!(:anime_video) { }
        it { expect(query.fetch).to be_empty }
      end
    end

    context 'vk' do
      let(:kind) { 'vk' }
      let!(:anime_video) { create :anime_video, :subtitles, anime: anime, episode: 1, url: 'https://vk.com/video_ext.php?oid=-32521137&id=171302170&hash=7753ad66fc1ed9ba' }

      context 'no missing videos' do
        let!(:anime_video_2) { create :anime_video, :subtitles, anime: anime, episode: 2, url: 'https://vk.com/video_ext.php?oid=-32521121&id=171302170&hash=7753ad66fc1ed9ba' }
        it { expect(query.fetch).to be_empty }
      end

      context 'missing video' do
        let!(:anime_video_2) { create :anime_video, :subtitles, anime: anime, episode: 2, url: 'http://myvi.ru/player/flash/oTX5PPFTxjkZZsHqI8dGBLfPI8flx20tXnkGHG2l5OQJJckIe1sS3EE-x8qepSVI50' }
        it { expect(query.fetch).to have(1).item }
      end
    end

    context 'subbed' do
      let(:kind) { 'subbed' }
      let!(:anime_video) { create :anime_video, :subtitles, anime: anime, episode: 1 }

      context 'no missing videos' do
        let!(:anime_video_2) { create :anime_video, :subtitles, anime: anime, episode: 2 }
        it { expect(query.fetch).to be_empty }
      end

      context 'missing video' do
        let!(:anime_video_2) { create :anime_video, :fandub, anime: anime, episode: 2 }
        it { expect(query.fetch).to have(1).item }
      end
    end

    context 'dubbed' do
      let(:kind) { 'subbed' }
      let!(:anime_video) { create :anime_video, :fandub, anime: anime, episode: 1 }

      context 'no missing videos' do
        let!(:anime_video_2) { create :anime_video, :fandub, anime: anime, episode: 2 }
        it { expect(query.fetch).to be_empty }
      end

      context 'missing video' do
        let!(:anime_video_2) { create :anime_video, :subtitles, anime: anime, episode: 2 }
        it { expect(query.fetch).to have(1).item }
      end
    end

    context 'unexpected kind' do
      let(:kind) { 'zzz' }
      it { expect{query.fetch}.to raise_error ArgumentError, "unexpected kind: #{kind}" }
    end
  end
end
