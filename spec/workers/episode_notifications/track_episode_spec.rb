describe EpisodeNotifications::TrackEpisode do
  let(:worker) { EpisodeNotifications::TrackEpisode.new }
  before do
    if has_error
      stub_const 'EpisodeNotifications::TrackEpisode::BOT_ID', bot.id
      stub_const 'EpisodeNotifications::TrackEpisode::VIDEO_MODERATION_TOPIC_ID', topic.id

      allow(EpisodeNotification::TrackEpisode)
        .to receive(:call)
        .and_raise MissingEpisodeError.new(anime.id, episode)
    else
      allow(EpisodeNotification::TrackEpisode).to receive :call
    end
  end
  let(:has_error) { false }
  let(:anime) { create :anime }
  subject! { worker.perform episode_notification.id }

  context 'present episode_notification' do
    let(:episode_notification) { create :episode_notification, anime: anime }
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

  context 'failed episode notification' do
    let(:episode_notification) { create :episode_notification, anime: anime }
    let(:has_error) { true }

    let(:episode) { 999 }
    let(:bot) { create :user }
    let(:topic) { create :topic }

    it do
      expect(EpisodeNotification::TrackEpisode)
        .to have_received(:call)
        .with(episode_notification)
      is_expected.to be_kind_of Comment
      is_expected.to have_attributes(
        commentable: topic,
        body: worker.send(:generate_report, anime.id, episode) + "\n[broadcast]",
        user: bot
      )
    end
  end
end
