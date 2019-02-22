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
            .and_raise MissingEpisodeError.new(anime.id, episode)
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

  describe 'instance methods' do
    describe '#rollback' do
      let(:episode_notification) do
        create :episode_notification,
          episode: episode,
          anime: anime,
          is_raw: is_raw,
          is_torrent: is_torrent
      end
      let(:anime) { create :anime, episodes_aired: episodes_aired }
      let(:episode) { 10 }
      let(:episodes_aired) { 10 }

      before { allow(Anime::RollbackEpisode).to receive(:call).and_call_original }
      subject! { episode_notification.rollback :raw }

      context 'true => false' do
        context 'last positive field' do
          let(:is_raw) { true }
          let(:is_torrent) { false }

          context 'episode >= anime.episodes_aired' do
            let(:episodes_aired) { 10 }
            it do
              expect(Anime::RollbackEpisode).to have_received :call
              expect { episode_notification.reload }.to raise_error ActiveRecord::RecordNotFound
            end
          end

          context 'episode < anime.episodes_aired' do
            let(:episodes_aired) { 11 }
            it do
              expect(Anime::RollbackEpisode).to_not have_received :call
              expect(episode_notification).to_not be_changed
              expect(episode_notification.reload.raw?).to eq false
              expect(episode_notification.torrent?).to eq false
            end
          end
        end

        context 'not last positive field' do
          let(:is_raw) { true }
          let(:is_torrent) { true }
          it do
            expect(episode_notification).to_not be_changed
            expect(episode_notification.reload.raw?).to eq false
            expect(episode_notification.torrent?).to eq true
          end
        end
      end

      context 'false => false' do
        let(:is_raw) { false }
        let(:is_torrent) { true }

        it do
          expect(episode_notification).to_not be_changed
          expect(episode_notification.raw?).to eq false
          expect(episode_notification.torrent?).to eq true
        end
      end
    end
  end
end
