class AnimeOnline::DashboardController < ShikimoriController
  def show
    @page = [params[:page].to_i, 1].max
    @limit = 8

    @recent_videos, @add_postloader = Rails.cache.fetch [:recent_videos, is_adult, EpisodeNotification.last, @page, @limit] do
      RecentVideosQuery.new(is_adult).postload(@page, @limit)
    end
    @recent_videos = @recent_videos.map {|v| AnimeWithEpisode.new v.anime.decorate, v }

    unless json?
      @ongoings = Anime
        .includes(:genres)
        .where(status: :ongoing)
        .where.not(rating: 'G - All Ages')
        .where('score < 9.9')
        .where(is_adult ? AnimeVideo::XPLAY_CONDITION : { kind: :tv, censored: false })
        .order(AniMangaQuery.order_sql 'ranked', Anime)
        .limit(15).decorate

      @contributors = Rails.cache.fetch [:video_contributors, is_adult], expires_in: 2.days do
        AnimeOnline::Contributors.top(20, is_adult).map(&:decorate)
      end
      @seasons = AniMangaSeason.menu_seasons
      @seasons.delete_at(2)
    end
  end

  def pingmedia_test_1
  end

  def pingmedia_test_2
  end

  def advertur_test
  end

  private

  def is_adult
    @is_adult ||= AnimeOnlineDomain::adult_host? request
  end
end
