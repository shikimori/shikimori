class ModerationsController < ShikimoriController
  before_action :authenticate_user!

  before_action { breadcrumb i18n_t('title'), moderations_url }
  before_action { page_title i18n_t('title') }

  def show
    @moderation_policy = ModerationPolicy.new(
      current_user,
      locale_from_host,
      false
    )

    if current_user.admin?
      @abuse_requests = AbuseRequest
        .where('created_at > ?', 3.month.ago)
        .where('user_id != approver_id')
        .group(:approver_id)
        .select('approver_id, count(*) as count')
        .where(approver_id: User::Roles::MODERATORS - User::Roles::ADMINS)
        .sort_by(&:count)
        .reverse

      @bans = Ban
        .where("created_at > ?", 3.month.ago)
        .where('user_id != moderator_id')
        .group(:moderator_id)
        .select('moderator_id, count(*) as count')
        .where(moderator_id: User::Roles::MODERATORS - User::Roles::ADMINS)
        .sort_by(&:count)
        .reverse

      @versions = Version
        .where("created_at > ?", 6.month.ago)
        .where('user_id != moderator_id')
        .group(:moderator_id)
        .select('moderator_id, count(*) as count')
        .where(moderator_id: User::Roles::VERSIONS_MODERATORS - User::Roles::ADMINS)
        .sort_by(&:count)
        .reverse
    end
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
      @collection = Rails.cache.fetch [:missing_videos, params[:kind], :v2], expires_in: 1.hour do
        Moderation::MissingVideosQuery.new(params[:kind]).animes
      end
    end
  end

  def missing_episodes
    @anime = Anime.find(
      CopyrightedIds.instance.restore(params[:anime_id], 'anime')
    )
    @episodes = Moderation::MissingVideosQuery.new(params[:kind]).episodes @anime
  end
end
