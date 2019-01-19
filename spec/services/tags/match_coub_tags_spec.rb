describe Tags::MatchCoubTags do
  let!(:anime_1) { create :anime, name: 'qqq', coub_tags: %w[zxc fofo] }
  let!(:anime_2) do
    create :anime,
      name: 'qqq',
      coub_tags: %w[zxc fofo],
      desynced: %w[coub_tags]
  end
  let!(:anime_3) { create :anime, name: 'qqq', coub_tags: [] }
  let!(:anime_4) { create :anime, name: 'www', coub_tags: [] }

  subject! { described_class.call %w[zxc fofo qqq] }

  it do
    expect(anime_1.reload.coub_tags).to eq %w[qqq]
    expect(anime_2.reload.coub_tags).to eq %w[zxc fofo]
    expect(anime_3.reload.coub_tags).to eq %w[qqq]
    expect(anime_4.reload.coub_tags).to eq []
  end
end
