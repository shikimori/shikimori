describe EpisodeNotification do
  describe 'relations' do
    it { is_expected.to belong_to :anime }
  end

  describe '#callbacks' do
    describe '#track_episode' do
      before do
        if missing_episode_error
          allow(EpisodeNotification::TrackEpisode)
            .to receive(:call)
            .and_raise MissingEpisodeError.new(episode, anime.id)
        else
          allow(EpisodeNotification::TrackEpisode).to receive :call
        end

        allow(EpisodeNotifications::TrackEpisode)
          .to receive(:set)
          .and_return track_episode_worker
      end
      let(:missing_episode_error) { false }
      let(:track_episode_worker) { double perform_async: nil }

      let!(:episode_notification) do
        create :episode_notification, :with_track_episode,
          anime: anime,
          episode: episode
      end
      let(:anime) { create :anime, episodes_aired: 2, episodes: 4 }

      context 'episodes_aired == episode' do
        let(:episode) { anime.episodes_aired }
        it do
          expect(EpisodeNotification::TrackEpisode).to_not have_received :call
          expect(EpisodeNotifications::TrackEpisode).to_not have_received :set
          expect(track_episode_worker).to_not have_received :perform_async
        end
      end

      context 'episodes_aired < episode' do
        let(:episode) { anime.episodes_aired + 1 }

        context 'valid episode' do
          it do
            expect(EpisodeNotification::TrackEpisode)
              .to have_received(:call)
              .with(episode_notification)
            expect(EpisodeNotifications::TrackEpisode).to_not have_received :set
            expect(track_episode_worker).to_not have_received :perform_async
          end
        end

        context 'invalid episode' do
          let(:missing_episode_error) { true }

          it do
            expect(EpisodeNotification::TrackEpisode)
              .to have_received(:call)
              .with(episode_notification)
            expect(EpisodeNotifications::TrackEpisode)
              .to have_received(:set)
              .with(wait: 5.seconds)
            expect(track_episode_worker)
              .to have_received(:perform_async)
              .with(episode_notification.id)
          end
        end
      end
    end
  end
end
