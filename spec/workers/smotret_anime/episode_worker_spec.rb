describe SmotretAnime::EpisodeWorker, :vcr do
  include_context :timecop
  let(:now) { 'Tue, 11 Jun 2019 22:40:03 MSK +03:00' }

  subject(:perform) { described_class.new.perform anime.id, smotret_anime_id }

  let(:anime) do
    create :anime, :ongoing, :tv,
      episodes: 12,
      episodes_aired: episodes_aired
  end
  let(:smotret_anime_id) { 15527 }
  let(:episodes_aired) { 6 }

  context 'released just now' do
    it do
      expect(subject).to have(2).items
      expect(anime.reload.episodes_aired).to eq 8
      expect(anime.episode_notifications).to have(2).item
      expect(anime.episode_notifications.last).to have_attributes(
        episode: 8,
        created_at: Time.zone.parse('2019-05-28 21:44:33 +0300'),
        is_raw: false,
        is_subtitles: false,
        is_fandub: false,
        is_anime365: true
      )
    end
  end

  context 'released long ago' do
    let(:now) { 'Tue, 12 Jun 2019 22:40:03 MSK +03:00' }
    it do
      expect(subject).to have(3).items
      expect(anime.reload.episodes_aired).to eq 9
      expect(anime.episode_notifications).to have(3).items
    end
  end

  context 'episodes_aired > released episodes in smotret-anime' do
    let(:episodes_aired) { 8 }
    it do
      expect(subject).to have(0).items
      expect(anime.reload.episodes_aired).to eq 8
      expect(anime.episode_notifications).to be_empty
    end
  end

  context 'broken smotret-anime link' do
    let(:smotret_anime_id) { 999999999 }

    let!(:external_link_1) { create :external_link, source: :shikimori, entry: anime }
    let!(:external_link_2) { create :external_link, source: :smotret_anime, entry: anime }
    let!(:external_link_3) { create :external_link, source: :myanimelist, entry: anime }

    subject! { perform }

    it do
      expect(anime.reload.episodes_aired).to eq 6
      expect(anime.episode_notifications).to be_empty

      expect(external_link_1.reload).to be_persisted
      expect { external_link_2.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(external_link_3.reload).to be_persisted
    end
  end
end
