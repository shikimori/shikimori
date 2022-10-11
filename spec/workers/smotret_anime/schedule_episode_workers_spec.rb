describe SmotretAnime::ScheduleEpisodeWorkers do
  before { allow(SmotretAnime::EpisodeWorker).to receive :perform_async }

  let!(:anime_1) { create :anime, :ongoing, score: 9 }
  let!(:anime_2) { create :anime, :released }
  let!(:anime_3) { create :anime, :ongoing, score: 9 }
  let!(:anime_4) { create :anime, :ongoing, score: 9 }
  let!(:anime_5) { create :anime, :ongoing, score: 7 }

  let!(:external_link_1) do
    create :external_link,
      source: :smotret_anime,
      kind: :smotret_anime,
      entry: anime_1,
      url: format(SmotretAnime::LinkWorker::ANIME365_URL, smotret_anime_id: -1)
  end
  let!(:external_link_2) do
    create :external_link,
      source: :smotret_anime,
      kind: :smotret_anime,
      entry: anime_2,
      url: format(SmotretAnime::LinkWorker::ANIME365_URL, smotret_anime_id: 12)
  end
  let!(:external_link_3) do
    create :external_link,
      source: :smotret_anime,
      kind: :smotret_anime,
      entry: anime_3,
      url: format(SmotretAnime::LinkWorker::ANIME365_URL, smotret_anime_id: 23)
  end
  let!(:external_link_4) do
    create :external_link,
      source: :smotret_anime,
      kind: :smotret_anime,
      entry: anime_4,
      url: format(SmotretAnime::LinkWorker::ANIME365_URL, smotret_anime_id: 34)
  end
  let!(:external_link_5) do
    create :external_link,
      source: :smotret_anime,
      kind: :smotret_anime,
      entry: anime_5,
      url: format(SmotretAnime::LinkWorker::ANIME365_URL, smotret_anime_id: 45)
  end

  subject! { described_class.new.perform group }

  context 'a' do
    let(:group) { described_class::Group[:a] }
    it do
      expect(SmotretAnime::EpisodeWorker)
        .to have_received(:perform_async)
        .twice
      expect(SmotretAnime::EpisodeWorker)
        .to have_received(:perform_async)
        .with anime_3.id, 23
      expect(SmotretAnime::EpisodeWorker)
        .to have_received(:perform_async)
        .with anime_4.id, 34
    end

    context 'disabled_anime365_sync' do
      let!(:anime_4) { create :anime, :ongoing, :disabled_anime365_sync, score: 9 }

      it do
        expect(SmotretAnime::EpisodeWorker)
          .to have_received(:perform_async)
          .once
        expect(SmotretAnime::EpisodeWorker)
          .to have_received(:perform_async)
          .with anime_3.id, 23
      end
    end
  end

  context 'b' do
    let(:group) { described_class::Group['b'] }
    it do
      expect(SmotretAnime::EpisodeWorker)
        .to have_received(:perform_async)
        .once
      expect(SmotretAnime::EpisodeWorker)
        .to have_received(:perform_async)
        .with anime_5.id, 45
    end
  end
end
