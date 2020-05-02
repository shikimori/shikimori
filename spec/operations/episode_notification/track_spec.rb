describe EpisodeNotification::Track do
  include_context :timecop

  let!(:episode_notification) { nil }
  let(:anime) { create :anime, status, episodes_aired: episodes_aired, episodes: 4 }

  let(:status) { :ongoing }
  let(:episodes_aired) { 2 }

  before { allow(EpisodeNotification::TrackEpisode).to receive(:call).and_call_original }

  let(:params) do
    {
      anime: anime,
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

  describe 'tracking logic' do
    subject! { described_class.call params }

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
          is_expected.to be_nil
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

  describe 'validation' do
    let(:is_anime365) { true }
    subject { described_class.call params }

    context 'released' do
      let(:status) { :released }

      context 'episode > anime.episodes' do
        let(:episode) { 5 }

        it do
          expect { subject }.to raise_error(
            ActiveRecord::RecordNotSaved,
            format(
              described_class::EPISODES_MESSAGE,
              episode: episode,
              anime_id: anime.id,
              episodes: anime.episodes
            )
          )
        end
      end

      context 'episode > anime.episodes_aired + maximum_allowed_episode_change' do
        let(:episodes_aired) { 0 }
        let(:episode) { 4 }

        it do
          is_expected.to be_persisted
          expect(anime.episode_notifications).to have(1).item
        end
      end
    end

    context 'ongoing' do
      context 'episode > anime.episodes_aired + maximum_allowed_episode_change' do
        let(:episodes_aired) { 0 }
        let(:episode) { 4 }

        it do
          expect { subject }.to raise_error(
            ActiveRecord::RecordNotSaved,
            format(
              described_class::EPISODES_AIRED_MESSAGE,
              episode: episode,
              anime_id: anime.id,
              episodes_aired: anime.episodes_aired
            )
          )
        end
      end

      context 'episode <= anime.episodes_aired + maximum_allowed_episode_change' do
        let(:episodes_aired) { 0 }
        let(:episode) { 3 }

        it do
          is_expected.to be_persisted
          expect(anime.episode_notifications).to have(1).item
        end
      end
    end
  end
end
