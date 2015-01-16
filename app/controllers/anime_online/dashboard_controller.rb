class AnimeOnline::DashboardController < AnimeOnlineController
  def show
    @page = [params[:page].to_i, 1].max
    @limit = 8

    @recent_videos, @add_postloader = RecentVideosQuery.new(AnimeOnlineDomain::adult_host?(request)).postload(@page, @limit)
    @recent_videos = @recent_videos.map {|v| AnimeWithEpisode.new v.anime.decorate, v }

    unless json?
      @ongoings = Anime
        .includes(:genres)
        .ongoing
        .where(kind: 'TV', censored: false)
        .where.not(rating: 'G - All Ages')
        .where('score < 9.9')
        .order(score: :desc)
        .limit(15)
        .decorate

      @contributors = AnimeOnline::Uploaders.current_top.map(&:decorate).take(15)
      @seasons = AniMangaSeason.menu_seasons
      @seasons.delete_at(2)
    end
  end
end
