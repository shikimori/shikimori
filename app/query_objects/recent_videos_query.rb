class RecentVideosQuery < QueryObjectBase
  pattr_initialize :is_adult

private
  def query
    EpisodeNotification
      .where(id: episode_ids)
      .joins(:anime)
      .where("(#{AniMangaStatus.query_for('ongoing', Anime)}) or released_on > ?", 1.month.ago)
      .where.not(animes: { rating: 'G - All Ages' }, id: Anime::EXCLUDED_ONGOINGS)
      .order('episode_notifications.updated_at desc')
  end

  def episode_ids
    EpisodeNotification
      .joins(:anime)
      .where('is_subtitles = true or is_fandub = true or is_raw = true or is_unknown = true')
      .where(is_adult ? AnimeVideo::XPLAY_CONDITION : AnimeVideo::PLAY_CONDITION)
      .group(:anime_id)
      .select('max(episode_notifications.id) as id')
  end
end
