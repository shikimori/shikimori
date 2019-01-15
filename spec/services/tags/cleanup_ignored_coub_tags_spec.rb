describe Tags::CleanupIgnoredCoubTags do
  let!(:anime_1) { create :anime, coub_tags: %w[z c], desynced: %w[coub_tags name] }
  let!(:anime_2) { create :anime, coub_tags: %w[z], desynced: %w[coub_tags name] }
  let!(:anime_3) { create :anime, coub_tags: %w[x] }

  before do
    allow_any_instance_of(Tags::CoubConfig)
      .to receive(:ignored_tags)
      .and_return %w[z]
  end
  subject! { described_class.call }

  it do
    expect(anime_1.reload.coub_tags).to eq %w[c]
    expect(anime_1.desynced).to eq %w[coub_tags name]
    expect(anime_2.reload.coub_tags).to eq %w[]
    expect(anime_2.desynced).to eq %w[name]
    expect(anime_3.reload.coub_tags).to eq %w[x]
  end
end
