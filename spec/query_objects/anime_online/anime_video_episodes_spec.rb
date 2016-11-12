describe AnimeOnline::FilterSovetRomantica do
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
        url: 'http://myvi.ru/player/embed/html/o2uWMvJRKqAyXG2EJUGGwUUKZwjleODmTYy0zGlks1-J5IO6Aexc_mKSgpudtZ7Zn0',
        anime: anime
    end
    let!(:anime_video_3) do
      create :anime_video, :fandub,
        episode: 2,
        url: 'http://myvi.ru/player/embed/html/preloader.swf?id=ooS23CgoxYNdHcm9FqwDb664Lbqhd1v7gyl7jDKc3O1xQ3-g0VOYjzoru3F35w6Ia0',
        anime: anime
    end

    subject(:anime_video_episodes) { query.call }

    it do
      expect(anime_video_episodes).to have(2).items
      expect(anime_video_episodes.first).to be_kind_of AnimeOnline::AnimeVideoEpisode
      expect(anime_video_episodes.first).to have_attributes(
        episode: 1,
        kinds: %w(fandub subtitles),
        hostings: %w(vk.com myvi.ru)
      )
      expect(anime_video_episodes.last).to have_attributes(
        episode: 2,
        kinds: %w(fandub),
        hostings: %w(myvi.ru)
      )
    end
  end
end
