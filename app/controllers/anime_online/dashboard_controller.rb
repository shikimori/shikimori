class AnimeOnline::DashboardController < ShikimoriController
  def show
    redirect_to '/animes/genre/12-Hentai' if is_adult

    @page = [params[:page].to_i, 1].max
    @limit = 8

    @recent_videos, @add_postloader = Rails.cache.fetch [:recent_videos, is_adult, EpisodeNotification.last, @page, @limit] do
      AnimeOnline::RecentVideos.new(is_adult).postload(@page, @limit)
    end
    @recent_videos = @recent_videos.map do |video|
      AnimeWithEpisode.new video.anime.decorate, video
    end

    unless json?
      @ongoings = Animes::OngoingsQuery.new(is_adult).fetch(15).decorate

      @contributors = Rails.cache.fetch [:video_contributors, is_adult], expires_in: 2.days do
        AnimeOnline::Contributors.top(20, is_adult).map(&:decorate)
      end
      @seasons = Menus::TopMenu.new.anime_seasons
      @seasons.delete_at(2)
    end
  end

private

  def is_adult
    false
  end
end
