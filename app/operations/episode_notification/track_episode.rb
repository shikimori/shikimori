class EpisodeNotification::TrackEpisode
  method_object :notification

  def call
    raise build_error(@notification) if missing_episode? @notification
    return if present_episode? @notification

    EpisodeNotification.transaction do
      Shikimori::DOMAIN_LOCALES.each do |locale|
        generate_topic @notification, locale
      end
      @notification.anime.update episodes_aired: @notification.episode
    end
  end

private

  def generate_topic episode_notification, locale
    Topics::Generate::News::EpisodeTopic.call(
      model: episode_notification.anime,
      user: episode_notification.anime.topic_user,
      locale: locale,
      aired_at: episode_notification.created_at,
      episode: episode_notification.episode
    )
  end

  def build_error episode_notification
    MissingEpisodeError.new(
      episode_notification.episode,
      episode_notification.anime_id
    )
  end

  def missing_episode? episode_notification
    episode_notification.anime.episodes.positive? &&
      episode_notification.episode > episode_notification.anime.episodes
  end

  def present_episode? episode_notification
    episode_notification.episode <= episode_notification.anime.episodes_aired
  end
end
