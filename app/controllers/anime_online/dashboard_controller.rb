class AnimeOnline::DashboardController < AnimeOnlineController
  def show
    #anime_ids = anime_query.search.order.page.fetch_ids
    #@animes = AnimeVideoDecorator.decorate_collection anime_query.search.order.page.fetch_entries
    @recent_videos = AnimeVideosQuery.new(AnimeOnlineDomain::adult_host?(request), params)
      .search
      .order
      .fetch_entries
      .limit(8)

    @ongoings = Anime
      .includes(:genres)
      .ongoing
      .where(kind: 'TV', censored: false)
      .order(score: :desc)
      .limit(12)

    @contributors = AnimeVideoReportsQuery.top_uploaders.map(&:decorate).take(12)
  end
end
