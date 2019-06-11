describe EpisodeNotification::Track do
  include_context :timecop

  let!(:episode_notification) { nil }
  let(:anime) { create :anime, :ongoing, episodes_aired: 2, episodes: 4 }

  subject! { described_class.call params }
  let(:params) do
    {
      anime_id: anime.id,
      episode: episode,
      aired_at: aired_at,
      is_raw: is_raw,
      is_subtitles: is_subtitles,
      is_fandub: is_fandub
    }
  end
  let(:episode) { 3 }
  let(:aired_at) { 1.week.ago }
  let(:is_raw) { false }
  let(:is_subtitles) { false }
  let(:is_fandub) { false }

  context 'has episode notification' do
    let!(:episode_notification) do
      create :episode_notification,
        anime: anime,
        episode: episode,
        is_raw: true
    end

    it do
      is_expected.to eq episode_notification
      expect(episode_notification.reload.is_raw).to eq true
      expect(episode_notification.created_at).to be_within(0.1).of Time.zone.now
      expect(anime.episode_notifications).to have(1).item
    end
  end

  context 'no episode notification' do
    let(:is_raw) { true }
    let(:is_subtitles) { true }
    let(:is_fandub) { true }

    it do
      is_expected.to be_persisted
      is_expected.to have_attributes(
        anime_id: anime.id,
        episode: episode,
        is_raw: is_raw,
        is_subtitles: is_subtitles,
        is_fandub: is_fandub
      )
      expect(subject.created_at).to be_within(0.1).of 1.week.ago
      expect(anime.episode_notifications).to have(1).item
      expect(anime.reload.episodes_aired).to eq episode
    end

    context 'no true values' do
      let(:is_raw) { false }
      let(:is_subtitles) { false }
      let(:is_fandub) { false }

      it do
        is_expected.to be_new_record
        expect(anime.episode_notifications).to be_empty
        expect(anime.reload.episodes_aired).to eq 2
      end
    end

    context 'no aired_at' do
      let(:aired_at) { nil }

      it do
        is_expected.to be_persisted
        is_expected.to have_attributes(
          anime_id: anime.id,
          episode: episode,
          is_raw: is_raw,
          is_subtitles: is_subtitles,
          is_fandub: is_fandub
        )
        expect(subject.created_at).to be_within(0.1).of Time.zone.now
        expect(anime.episode_notifications).to have(1).item
        expect(anime.reload.episodes_aired).to eq episode
      end
    end
  end
end
