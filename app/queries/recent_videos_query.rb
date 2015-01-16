class RecentVideosQuery
  PER_PAGE = 16

  pattr_initialize :is_adult

  def fetch
    EpisodeNotification
      .where(id: episode_ids)
      .joins(:anime)
      .where("(#{AniMangaStatus.query_for('ongoing', Anime)}) or released_on > ?", 1.month.ago)
      .where.not(animes: { rating: 'G - All Ages' })
      .limit(PER_PAGE)
  end

private
  def episode_ids
    EpisodeNotification
      .joins(:anime)
      .where(is_adult ? AnimeVideo::XPLAY_CONDITION : AnimeVideo::PLAY_CONDITION)
      .group(:anime_id)
      .select('max(episode_notifications.id) as id')
  end
end
