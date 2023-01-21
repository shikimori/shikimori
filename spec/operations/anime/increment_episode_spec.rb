describe Anime::IncrementEpisode do
  let(:anime) do
    create :anime, status, :with_track_changes,
      episodes_aired: episodes_aired,
      episodes: 100
  end
  let(:episodes_aired) { 10 }

  subject { described_class.call anime: anime, user: user, aired_at: aired_at }
  let(:aired_at) { Time.zone.now }

  let(:user) { user_admin }
  let(:status) { :anons }
  let(:episodes_aired) { 0 }

  it do
    expect { subject }.to change(Version, :count).by 1
    expect(subject).to be_persisted
    expect(subject).to_not be_changed
    expect(subject).to have_attributes(
      user: user,
      item: anime,
      state: 'auto_accepted',
      item_diff: {
        'episodes_aired' => [0, 1]
      }
    )

    expect(anime).to be_ongoing
    expect(anime.episodes_aired).to eq 1
  end
end
