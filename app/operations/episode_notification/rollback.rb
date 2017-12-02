class EpisodeNotification::Rollback
  method_object %i[anime_id! episode! kind!]

  def call
    EpisodeNotification
      .where(anime_id: anime_id, episode: episode)
      .each { |episode_notification| episode_notification.rollback kind }
  end
end
