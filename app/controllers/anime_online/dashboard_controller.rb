class AnimeOnline::DashboardController < ShikimoriController
  def show # rubocop:disable all
    # redirect_to '/animes/genre/12-Hentai' if adult?

    @limit = 8

    @recent_videos, @add_postloader =
      Rails.cache.fetch(
        [:recent_videos, adult?, EpisodeNotification.last, @page, @limit]
      ) do
        AnimeOnline::RecentVideos.new(adult?).postload(@page, @limit)
      end

    @recent_videos = @recent_videos.map do |video|
      AnimeWithEpisode.new video.anime.decorate, video
    end

    unless json?
      @ongoings = Animes::OngoingsQuery.new(adult?).fetch(15).decorate

      @contributors = Rails.cache.fetch(
        [:video_contributors, adult?],
        expires_in: 2.days
      ) do
        AnimeOnline::Contributors.call(
          limit: 20,
          is_adult: adult?
        ).map(&:decorate)
      end

      @seasons = Menus::TopMenu.new.anime_seasons
      @seasons.delete_at(2)
    end
  end

private

  def adult?
    false
  end
end
