describe EpisodeNotification::Rollback do
  let(:episode_notification) do
    build :episode_notification,
      anime_id: anime_id,
      episode: episode,
      is_subtitles: false
  end
  let(:anime_id) { 123 }
  let(:episode) { 1 }
  let(:kind) { :subtitles }

  before do
    allow(EpisodeNotification)
      .to receive(:where)
      .with(anime_id: anime_id, episode: episode)
      .and_return [episode_notification]
    allow(episode_notification).to receive :rollback
  end

  subject! do
    described_class.call(
      anime_id: anime_id,
      episode: episode,
      kind: kind
    )
  end

  it { expect(episode_notification).to have_received(:rollback).with kind }
end
