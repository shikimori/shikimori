class ModerationsController < ShikimoriController
  before_action :authenticate_user!

  before_action do
    breadcrumb i18n_t('title'), moderations_url
    og page_title: i18n_t('title')
  end

  def show
    @moderation_policy = ModerationPolicy.new current_user, locale_from_host

    if current_user.admin?
      @abuse_requests = AbuseRequest
        .where('created_at > ?', 3.month.ago)
        .where('user_id != approver_id')
        .group(:approver_id)
        .select('approver_id, count(*) as count')
        .where(
          approver_id: User.where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
        )
        .where.not(approver_id: User::MORR_ID)
        .sort_by(&:count)
        .reverse

      @bans = Ban
        .where('created_at > ?', 3.month.ago)
        .where('user_id != moderator_id')
        .group(:moderator_id)
        .select('moderator_id, count(*) as count')
        .where(
          moderator_id: User.where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
        )
        .where.not(moderator_id: User::MORR_ID)
        .sort_by(&:count)
        .reverse

      @versions = Version
        .where('created_at > ?', 6.month.ago)
        .where('user_id != moderator_id')
        .group(:moderator_id)
        .select('moderator_id, count(*) as count')
        .where(
          moderator_id: User.where("roles && '{#{Types::User::Roles[:version_moderator]}}'")
        )
        .where.not(moderator_id: User::MORR_ID)
        .sort_by(&:count)
        .reverse
    end
  end

  def missing_screenshots
    og page_title: i18n_t('missing_screenshots_title')

    @collection = Rails.cache.fetch :missing_screenshots, expires_in: 1.hour do
      Moderation::MissingScreenshotsQuery.new.fetch
    end
  end

  def missing_videos
    og page_title: i18n_t('missing_videos_title')

    if params[:kind]
      breadcrumb i18n_t('missing_videos_title'), missing_videos_moderations_url
      og page_title: i18n_t("missing_videos.#{params[:kind]}")

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
