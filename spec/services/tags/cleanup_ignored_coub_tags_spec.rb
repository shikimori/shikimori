describe Tags::CleanupIgnoredCoubTags do
  let!(:anime_1) { create :anime, coub_tag: 'z', desynced: %w[coub_tag name] }
  let!(:anime_2) { create :anime, coub_tag: 'x' }

  before do
    allow_any_instance_of(Tags::CoubConfig)
      .to receive(:ignored_tags)
      .and_return %w[z]
  end
  subject! { described_class.call }

  it do
    expect(anime_1.reload.coub_tag).to be_nil
    expect(anime_1.desynced).to eq %w[name]
    expect(anime_2.reload.coub_tag).to eq 'x'
  end
end
