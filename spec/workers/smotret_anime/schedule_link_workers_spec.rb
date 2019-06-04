describe SmotretAnime::ScheduleLinkWorkers do
  before { allow(SmotretAnime::LinkWorker).to receive :perform_async }

  let!(:animes) { create_list :anime, 4 }

  let!(:external_link_1) do
    create :external_link,
      source: :smotret_anime,
      kind: :smotret_anime,
      entry: animes[0],
      url: format(SmotretAnime::LinkWorker::SMOTRET_ANIME_URL, smotret_anime_id: -1)
  end
  let!(:external_link_2) do
    create :external_link,
      source: :smotret_anime,
      kind: :smotret_anime,
      entry: animes[1],
      url: format(SmotretAnime::LinkWorker::SMOTRET_ANIME_URL, smotret_anime_id: 1)
  end

  subject! { described_class.new.perform }

  it do
    expect(SmotretAnime::LinkWorker)
      .to have_received(:perform_async)
      .twice
    expect(SmotretAnime::LinkWorker)
      .to have_received(:perform_async)
      .with animes[2].id
    expect(SmotretAnime::LinkWorker)
      .to have_received(:perform_async)
      .with animes[3].id
  end
end
