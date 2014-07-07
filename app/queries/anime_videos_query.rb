class AnimeVideosQuery
  PER_PAGE = 40

  def initialize is_adult
    @is_adult = is_adult
  end

  def fetch
    Anime
      .joins(:anime_videos)
      .where(@is_adult ? AnimeVideo::XPLAY_CONDITION : AnimeVideo::PLAY_CONDITION)
      .order('max(anime_videos.created_at) desc')
      .group('animes.id')
  end
end
