describe AnimeOnline::AnimeVideoEpisodes do
  let(:query) { AnimeOnline::AnimeVideoEpisodes.new anime }

  describe '#call' do
    let!(:anime) { create :anime }
    let!(:anime_video_1) do
      create :anime_video, :subtitles,
        episode: 1,
        url: 'http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7',
        anime: anime
    end
    let!(:anime_video_2) do
      create :anime_video, :fandub,
        episode: 1,
        url: 'https://www.youtube.com/watch?v=69ValEBy1YY',
        anime: anime
    end
    let!(:anime_video_3) do
      create :anime_video, :fandub,
        episode: 2,
        url: 'https://www.youtube.com/watch?v=PSILIiORs6Q',
        anime: anime
    end

    subject(:anime_video_episodes) { query.call }

    it do
      expect(anime_video_episodes).to have(2).items
      expect(anime_video_episodes.first).to be_kind_of AnimeOnline::AnimeVideoEpisode
      expect(anime_video_episodes.first).to have_attributes(
        episode: 1,
        kinds: %i[fandub subtitles],
        hostings: %i[vk youtube]
      )
      expect(anime_video_episodes.last).to have_attributes(
        episode: 2,
        kinds: %i[fandub],
        hostings: %i[youtube]
      )
    end
  end
end
