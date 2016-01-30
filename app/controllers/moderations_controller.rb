class ModerationsController < ShikimoriController
  before_action :authenticate_user!

  before_action { breadcrumb i18n_t('title'), moderations_url }
  before_action { page_title i18n_t('title') }

  def show
  end

  def missing_screenshots
    page_title i18n_t('missing_screenshots_title')

    @collection = Rails.cache.fetch :missing_screenshots, expires_in: 1.hour do
      Moderation::MissingScreenshotsQuery.new.fetch
    end
  end

  def missing_videos
    page_title i18n_t('missing_videos_title')

    if params[:kind]
      breadcrumb i18n_t('missing_videos_title'), missing_videos_moderations_url
      page_title i18n_t("missing_videos.#{params[:kind]}")
      @collection = Rails.cache.fetch [:missing_videos, params[:kind]], expires_in: 1.hour do
        Moderation::MissingVideosQuery.new(params[:kind]).animes
      end
    end
  end

  def missing_episodes
    @anime = Anime.find params[:anime_id]
    @episodes = Moderation::MissingVideosQuery.new(params[:kind]).episodes @anime
  end
end
