describe PgCaches::Cleanup do
  let!(:entry_1) { create :pg_cache_data, expires_at: nil }
  let!(:entry_2) { create :pg_cache_data, expires_at: 1.minute.ago }
  let!(:entry_3) { create :pg_cache_data, expires_at: 1.minute.from_now }

  subject! { described_class.new.perform }

  it do
    expect(entry_1.reload).to be_persisted
    expect { entry_2.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(entry_3.reload).to be_persisted
  end
end
