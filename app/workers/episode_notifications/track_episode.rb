class EpisodeNotifications::TrackEpisode
  include Sidekiq::Worker
  sidekiq_options queue: :episode_notifications

  def perform episode_notification_id
    episode_notification = find episode_notification_id
    return unless episode_notification

    EpisodeNotification::TrackEpisode.call episode_notification
  end

private

  def find episode_notification_id
    EpisodeNotification.find_by id: episode_notification_id
  end
end
