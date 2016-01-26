class AnimeOnline::DashboardController < ShikimoriController
  def show
    @page = [params[:page].to_i, 1].max
    @limit = 8

    @recent_videos, @add_postloader = Rails.cache.fetch [:recent_videos, is_adult, EpisodeNotification.last, @page, @limit] do
      RecentVideosQuery.new(is_adult).postload(@page, @limit)
    end
    @recent_videos = @recent_videos.map {|v| AnimeWithEpisode.new v.anime.decorate, v }

    unless json?
      @ongoings = OngoingsQuery.new(is_adult).fetch(15).decorate

      @contributors = Rails.cache.fetch [:video_contributors, is_adult], expires_in: 2.days do
        AnimeOnline::Contributors.top(20, is_adult).map(&:decorate)
      end
      @seasons = Menus::TopMenu.new.anime_seasons
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
