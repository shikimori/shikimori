class AnimeOnline::DashboardController < ShikimoriController
  before_action { redirect_to root_url(subdomain: false) unless ignore_copyright? }

  def show # rubocop:disable all
    # redirect_to '/animes/genre/12-Hentai' if adult?

    @limit = 8

    @recent_videos, @add_postloader =
      Rails.cache.fetch [:recent_videos, adult?, EpisodeNotification.last, @page, @limit] do
        AnimeOnline::RecentVideos.new(adult?).postload(@page, @limit)
      end

    @recent_videos = @recent_videos.map do |video|
      AnimeWithEpisode.new video.anime.decorate, video
    end

    unless json?
      @ongoings = Animes::OngoingsQuery.new(adult?).fetch(15).decorate

      @contributors = Rails.cache.fetch [:video_contributors, adult?], expires_in: 2.days do
        AnimeOnline::Contributors.call(
          limit: 20,
          is_adult: adult?
        ).map(&:decorate)
      end

      @seasons = anime_seasons
    end
  end

private

  def anime_seasons
    month = Time.zone.now.beginning_of_month
    # + 1.month since 12th month belongs to the next year in Titles::SeasonTitle
    # is_still_this_year = (month + 2.months + 1.month).year == month.year

    [
      Titles::StatusTitle.new(:ongoing, Anime),
      Titles::SeasonTitle.new(month + 2.months, :year, Anime),
      # Titles::SeasonTitle.new(is_still_this_year ? 1.year.ago : 2.months.ago, :year, Anime),
      Titles::SeasonTitle.new(month + 3.months, :season_year, Anime),
      Titles::SeasonTitle.new(month, :season_year, Anime),
      Titles::SeasonTitle.new(month - 3.months, :season_year, Anime),
      Titles::SeasonTitle.new(month - 6.months, :season_year, Anime)
    ]
  end

  def adult?
    false
  end
end
