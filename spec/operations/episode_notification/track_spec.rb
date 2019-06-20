describe EpisodeNotification::Track do
  include_context :timecop

  let!(:episode_notification) { nil }
  let(:anime) { create :anime, :ongoing, episodes_aired: 2, episodes: 4 }

  before { allow(EpisodeNotification::TrackEpisode).to receive(:call).and_call_original }

  subject! { described_class.call params }
  let(:params) do
    {
      anime_id: anime.id,
      episode: episode,
      aired_at: aired_at,
      is_raw: is_raw,
      is_subtitles: is_subtitles,
      is_fandub: is_fandub,
      is_anime365: is_anime365
    }
  end
  let(:episode) { 3 }
  let(:aired_at) { 1.week.ago }
  let(:is_raw) { false }
  let(:is_subtitles) { false }
  let(:is_fandub) { false }
  let(:is_anime365) { false }

  context 'has episode notification' do
    let!(:episode_notification) do
      create :episode_notification,
        anime: anime,
        episode: episode,
        is_raw: true
    end
    let(:is_anime365) { true }

    it do
      is_expected.to eq episode_notification
      expect(episode_notification.reload.is_raw).to eq true
      expect(episode_notification.created_at).to be_within(0.1).of Time.zone.now
      expect(anime.episode_notifications).to have(1).item
      expect(EpisodeNotification::TrackEpisode).to have_received :call
    end
  end

  context 'no episode notification' do
    let(:is_raw) { true }
    let(:is_subtitles) { [true, false].sample }
    let(:is_fandub) { [true, false].sample }
    let(:is_anime365) { [true, false].sample }

    it do
      is_expected.to be_persisted
      is_expected.to have_attributes(
        anime_id: anime.id,
        episode: episode,
        is_raw: is_raw,
        is_subtitles: is_subtitles,
        is_anime365: is_anime365
      )
      expect(subject.created_at).to be_within(0.1).of 1.week.ago
      expect(anime.episode_notifications).to have(1).item
      expect(anime.reload.episodes_aired).to eq episode
      expect(EpisodeNotification::TrackEpisode).to have_received :call
    end

    context 'no true values' do
      let(:is_raw) { false }
      let(:is_subtitles) { false }
      let(:is_fandub) { false }
      let(:is_anime365) { false }

      it do
        is_expected.to be_new_record
        expect(anime.episode_notifications).to be_empty
        expect(anime.reload.episodes_aired).to eq 2
        expect(EpisodeNotification::TrackEpisode).to_not have_received :call
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
          is_fandub: is_fandub,
          is_anime365: is_anime365
        )
        expect(subject.created_at).to be_within(0.1).of Time.zone.now
        expect(anime.episode_notifications).to have(1).item
        expect(anime.reload.episodes_aired).to eq episode
        expect(EpisodeNotification::TrackEpisode).to have_received :call
      end
    end
  end
end
