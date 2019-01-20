describe Tags::CleanupImageboardsCacheJob do
  let!(:pg_cache_1) { create :pg_cache_data, key: 'zxc' }
  let!(:pg_cache_2) do
    create :pg_cache_data,
      key: ImageboardsController.pg_cache_key(
        tag: anime_1.imageboard_tag,
        imageboard: described_class::IMAGEBOARDS.sample,
        page: 1 # described_class::PAGES.sample
      ),
      expires_at: ImageboardsController::EXPIRES_IN.from_now -
        described_class::ONGOING_EXPIRES_IN + 1.day
  end
  let!(:pg_cache_3) do
    create :pg_cache_data,
      key: ImageboardsController.pg_cache_key(
        tag: anime_1.imageboard_tag,
        imageboard: described_class::IMAGEBOARDS.sample,
        page: 2 # described_class::PAGES.sample
      ),
      expires_at: ImageboardsController::EXPIRES_IN.from_now -
        described_class::ONGOING_EXPIRES_IN - 1.day
  end
  let!(:pg_cache_4) do
    create :pg_cache_data,
      key: ImageboardsController.pg_cache_key(
        tag: anime_2.imageboard_tag,
        imageboard: described_class::IMAGEBOARDS.sample,
        page: 3 # described_class::PAGES.sample
      ),
      expires_at: ImageboardsController::EXPIRES_IN.from_now -
        described_class::ONGOING_EXPIRES_IN - 1.day
  end

  let!(:pg_cache_5) do
    create :pg_cache_data,
      key: ImageboardsController.pg_cache_key(
        tag: character_1.imageboard_tag,
        imageboard: described_class::IMAGEBOARDS.sample,
        page: 4 # described_class::PAGES.sample
      ),
      expires_at: ImageboardsController::EXPIRES_IN.from_now -
        described_class::ONGOING_EXPIRES_IN - 1.day
  end
  let!(:pg_cache_6) do
    create :pg_cache_data,
      key: ImageboardsController.pg_cache_key(
        tag: character_2.imageboard_tag,
        imageboard: described_class::IMAGEBOARDS.sample,
        page: 5 # described_class::PAGES.sample
      ),
      expires_at: ImageboardsController::EXPIRES_IN.from_now -
        described_class::ONGOING_EXPIRES_IN - 1.day
  end

  let!(:anime_1) { create :anime, :ongoing, imageboard_tag: 'one_piece' }
  let!(:anime_2) { create :anime, imageboard_tag: 'sword_art_online_character' }

  let!(:character_1) { create :character, imageboard_tag: 'z' }
  let!(:character_2) { create :character, imageboard_tag: 'x' }

  let!(:person_role_1) { create :person_role, anime: anime_1, character: character_1 }
  let!(:person_role_2) { create :person_role, anime: anime_2, character: character_2 }

  subject! { described_class.new.perform }

  it do
    expect(pg_cache_1.reload).to be_persisted
    expect(pg_cache_2.reload).to be_persisted
    expect { pg_cache_3.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(pg_cache_4.reload).to be_persisted
    expect { pg_cache_5.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(pg_cache_6.reload).to be_persisted
  end
end
