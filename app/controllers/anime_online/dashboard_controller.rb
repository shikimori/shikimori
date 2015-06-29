class AnimeOnline::DashboardController < ShikimoriController
  def show
    @page = [params[:page].to_i, 1].max
    @limit = 8

    @recent_videos, @add_postloader = RecentVideosQuery.new(is_adult).postload(@page, @limit)
    @recent_videos = @recent_videos.map {|v| AnimeWithEpisode.new v.anime.decorate, v }

    unless json?
      @ongoings = Anime.ongoing
        .includes(:genres)
        .where.not(rating: 'G - All Ages')
        .where('score < 9.9')
        .where(is_adult ? AnimeVideo::XPLAY_CONDITION : { kind: :tv, censored: false })
        .order(score: :desc)
        .limit(15).decorate

      @contributors = AnimeOnline::Contributors.top(20, is_adult).map(&:decorate)
      @seasons = AniMangaSeason.menu_seasons
      @seasons.delete_at(2)
    end
  end

  def pingmedia_test_1
  end

  def pingmedia_test_2
  end

  private

  def is_adult
    @is_adult ||= AnimeOnlineDomain::adult_host? request
  end
end
