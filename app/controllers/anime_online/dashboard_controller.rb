class AnimeOnline::DashboardController < AnimeOnlineController
  def show
    anime_query = AnimeVideosQuery.new AnimeOnlineDomain::adult_host?(request), params
    @anime_ids = anime_query.search.order.page.fetch_ids
    #@animes = AnimeVideoDecorator.decorate_collection anime_query.search.order.page.fetch_entries
    @animes = anime_query.search.order.page.fetch_entries
  end
end
