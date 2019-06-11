describe SmotretAnime::EpisodeWorker, :vcr do
  include_context :timecop
  subject! { described_class.new.perform anime.id, smotret_anime_id }

  let(:anime) do
    create :anime, :ongoing, :tv,
      episodes: 12,
      episodes_aired: episodes_aired
  end
  let(:smotret_anime_id) { 15527 }
  let(:episodes_aired) { 6 }

  context 'released just now' do
    let(:datetime) { 'Tue, 11 Jun 2019 22:40:03 MSK +03:00' }
    it do
      expect(anime.reload.episodes_aired).to eq 8
      expect(anime.episode_notifications).to have(2).item
      expect(anime.episode_notifications.last).to have_attributes(
        episode: 8,
        created_at: Time.zone.parse('2019-05-28 21:44:33 +0300'),
        is_raw: true,
        is_subtitles: false,
        is_fandub: false
      )
    end
  end

  context 'released long ago' do
    let(:datetime) { 'Tue, 12 Jun 2019 22:40:03 MSK +03:00' }
    it do
      expect(anime.reload.episodes_aired).to eq 9
      expect(anime.episode_notifications).to have(3).items
    end
  end
end
