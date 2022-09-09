class EpisodeNotification::TrackEpisode
  method_object :notification

  RELEASE_EXPIRATION_INTERVAL = 1.month

  def call
    raise missing_episode_error(@notification) if missing_episode? @notification

    generate_topic @notification

    return if present_episode? @notification
    return if old_released_anime? @notification

    @notification.anime.update episodes_aired: @notification.episode
  end

private

  def generate_topic episode_notification
    Topics::Generate::News::EpisodeTopic.call(
      model: episode_notification.anime,
      user: episode_notification.anime.topic_user,
      aired_at: episode_notification.created_at,
      episode: episode_notification.episode
    )
  end

  def missing_episode_error episode_notification
    MissingEpisodeError.new(
      episode_notification.anime_id,
      episode_notification.episode
    )
  end

  def missing_episode? episode_notification
    episode_notification.anime.episodes.positive? &&
      episode_notification.episode > episode_notification.anime.episodes
  end

  def present_episode? episode_notification
    episode_notification.episode <= episode_notification.anime.episodes_aired
  end

  def old_released_anime? episode_notification
    episode_notification.anime.released? &&
      episode_notification.anime.released_on &&
      episode_notification.anime.released_on < RELEASE_EXPIRATION_INTERVAL.ago
  end
end
