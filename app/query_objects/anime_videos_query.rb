class AnimeVideosQuery
  PER_PAGE = 40

  pattr_initialize :is_adult

  def fetch
    Anime
      .joins(:anime_videos)
      .where(is_adult ? AnimeVideo::XPLAY_CONDITION : AnimeVideo::PLAY_CONDITION)
      .order('max(anime_videos.created_at) desc')
      .group('animes.id')
  end
end
