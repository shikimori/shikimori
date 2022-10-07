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
      url: format(SmotretAnime::LinkWorker::SMOTRET_ANIME_URL, smotret_anime_id: 1),
      created_at: external_link_2_created_at
  end
  let(:external_link_2_created_at) { (described_class::LINK_EXPIRE_INTERVAL - 1.day).ago }

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

  context 'expired link' do
    let(:external_link_2_created_at) { (described_class::LINK_EXPIRE_INTERVAL + 1.day).ago }

    it do
      expect(SmotretAnime::LinkWorker)
        .to have_received(:perform_async)
        .thrice
      expect(SmotretAnime::LinkWorker)
        .to have_received(:perform_async)
        .with animes[1].id
      expect(SmotretAnime::LinkWorker)
        .to have_received(:perform_async)
        .with animes[2].id
      expect(SmotretAnime::LinkWorker)
        .to have_received(:perform_async)
        .with animes[3].id
    end
  end
end
