class AnimeOnline::DashboardController < AnimeOnlineController
  def show
    @recent_videos = AnimeVideosQuery.new(AnimeOnlineDomain::adult_host?(request))
      .fetch
      .limit(8)
      .decorate

    @ongoings = Anime
      .includes(:genres)
      .ongoing
      .where(kind: 'TV', censored: false)
      .where.not(rating: 'G - All Ages')
      .order(score: :desc)
      .limit(15)
      .decorate

    @contributors = AnimeOnline::Uploaders.current_top.map(&:decorate).take(15)
    @seasons = AniMangaSeason.menu_seasons
    @seasons.delete_at(2)
  end
end
