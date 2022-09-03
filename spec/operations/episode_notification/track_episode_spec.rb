describe EpisodeNotification::TrackEpisode do
  before { allow(Topics::Generate::News::EpisodeTopic).to receive :call }
  subject(:call) { described_class.call episode_notification }

  let!(:episode_notification) do
    create :episode_notification,
      anime: anime,
      episode: episode
  end
  let(:anime) do
    create :anime,
      episodes_aired: 2,
      episodes: 4,
      status: status,
      released_on: released_on
  end
  let(:status) { :ongoing }
  let(:released_on) { nil }

  context 'episode > anime.episodes' do
    let(:episode) { anime.episodes + 1 }
    it { expect { call }.to raise_error MissingEpisodeError }
  end

  context 'episode <= anime.episodes' do
    subject! { call }

    context 'episode == anime.episodes_aired' do
      let(:episode) { anime.episodes_aired }
      it do
        expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice
        expect(anime.episodes_aired).to eq 2
      end
    end

    context 'episode < anime.episodes_aired' do
      let(:episode) { anime.episodes_aired - 1 }
      it do
        expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice
        expect(anime.episodes_aired).to eq 2
      end
    end

    context 'episode > anime.episodes_aired' do
      let(:episode) { anime.episodes_aired + 1 }
      it do
        expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice

        expect(Topics::Generate::News::EpisodeTopic)
          .to have_received(:call)
          .with(
            model: episode_notification.anime,
            user: episode_notification.anime.topic_user,
            aired_at: episode_notification.created_at,
            episode: episode_notification.episode
          )

        expect(anime.reload.episodes_aired).to eq 3
      end

      describe 'old_released_anime?' do
        context 'old released anime' do
          let(:status) { :released }
          let(:released_on) { described_class::RELEASE_EXPIRATION_INTERVAL.ago - 1.day }
          it { expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice }
        end

        context 'old ongoing anime' do
          let(:status) { :ongoing }
          let(:released_on) { described_class::RELEASE_EXPIRATION_INTERVAL.ago - 1.day }
          it { expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice }
        end

        context 'new released anime' do
          let(:status) { :released }
          let(:released_on) { described_class::RELEASE_EXPIRATION_INTERVAL.ago + 1.day }
          it { expect(Topics::Generate::News::EpisodeTopic).to have_received(:call).twice }
        end
      end
    end
  end
end
