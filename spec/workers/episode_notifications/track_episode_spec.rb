describe EpisodeNotifications::TrackEpisode do
  let(:worker) { EpisodeNotifications::TrackEpisode.new }
  before { allow(EpisodeNotification::TrackEpisode).to receive :call }
  subject! { worker.perform episode_notification.id }

  context 'present episode_notification' do
    let(:episode_notification) { create :episode_notification, anime: create(:anime) }
    it do
      expect(EpisodeNotification::TrackEpisode)
        .to have_received(:call)
        .with(episode_notification)
    end
  end

  context 'missing episode_notification' do
    let(:episode_notification) { build_stubbed :episode_notification }
    it { expect(EpisodeNotification::TrackEpisode).to_not have_received :call }
  end
end
