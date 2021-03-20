describe Tags::CleanupCoubCacheJob do
  let!(:pg_cache_1) { create :pg_cache_data, key: 'zxc' }
  let!(:pg_cache_2) do
    create :pg_cache_data,
      key: Coubs::Request.pg_cache_key(
        tag: anime_1.coub_tags.first,
        page: described_class::PAGES.sample
      ),
      expires_at: Coubs::Request::EXPIRES_IN.from_now -
        described_class::ONGOING_EXPIRES_IN + 1.day
  end
  let!(:pg_cache_3) do
    create :pg_cache_data,
      key: Coubs::Request.pg_cache_key(
        tag: anime_1.coub_tags.last,
        page: described_class::PAGES.sample
      ),
      expires_at: Coubs::Request::EXPIRES_IN.from_now -
        described_class::ONGOING_EXPIRES_IN - 1.day
  end
  let!(:pg_cache_4) do
    create :pg_cache_data,
      key: Coubs::Request.pg_cache_key(
        tag: anime_2.coub_tags.sample,
        page: described_class::PAGES.sample
      ),
      expires_at: Coubs::Request::EXPIRES_IN.from_now -
        described_class::ONGOING_EXPIRES_IN - 1.day
  end

  let!(:anime_1) { create :anime, :ongoing, coub_tags: %w[one_piece zzz] }
  let!(:anime_2) { create :anime, coub_tags: %w[naruto xxx] }

  subject! { described_class.new.perform }

  it do
    expect(pg_cache_1.reload).to be_persisted
    expect(pg_cache_2.reload).to be_persisted
    expect { pg_cache_3.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(pg_cache_4.reload).to be_persisted
  end
end
