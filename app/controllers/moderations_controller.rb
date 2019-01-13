class ModerationsController < ShikimoriController
  before_action :authenticate_user!

  before_action do
    breadcrumb i18n_t('title'), moderations_url
    og page_title: i18n_t('title')
  end

  def show
    @moderation_policy = ModerationPolicy.new(
      current_user,
      locale_from_host,
      false
    )

    if can? :manage_forum_moderator_role, User
      @abuse_requests_stats = abuse_requests_stats
      @bans_stats = bans_stats
    end

    if can? :manage_version_moderator_role, User
      @content_versions_stats = content_versions_stats
    end

    if can? :manage_video_moderator_role, User
      @video_versions_stats = video_versions_stats
      @anime_video_reports_stats = anime_video_reports_stats
    end
  end

  def missing_screenshots
    og page_title: i18n_t('missing_screenshots_title')

    @collection = Rails.cache.fetch :missing_screenshots, expires_in: 1.hour do
      Moderation::MissingScreenshotsQuery.new.fetch
    end
  end

  def missing_videos # rubocop:disable AbcSize
    og page_title: i18n_t('missing_videos_title')

    if params[:kind]
      breadcrumb i18n_t('missing_videos_title'), missing_videos_moderations_url
      og page_title: i18n_t("missing_videos.#{params[:kind]}")

      @collection = Rails.cache.fetch [:missing_videos, params[:kind], :v4], expires_in: 1.hour do
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

private

  def abuse_requests_stats
    Rails.cache.fetch %i[abuse_requests_stats v4], expires_in: 1.day do
      AbuseRequest
        .where('created_at > ?', 4.month.ago)
        .group(:approver_id)
        .select('approver_id, count(*) as count')
        .where(
          approver_id: User.where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
        )
        .sort_by(&:count)
        .reverse
    end
  end

  def bans_stats
    Rails.cache.fetch %i[bans_stats v4], expires_in: 1.day do
      Ban
        .where('created_at > ?', 4.month.ago)
        .group(:moderator_id)
        .select('moderator_id, count(*) as count')
        .where(
          moderator_id: User.where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
        )
        .sort_by(&:count)
        .reverse
    end
  end

  def content_versions_stats
    Rails.cache.fetch %i[content_versions_stats v4], expires_in: 1.day do
      Version
        .where('created_at > ?', 4.month.ago)
        .where.not(item_type: AnimeVideo.name)
        .group(:moderator_id)
        .select('moderator_id, count(*) as count')
        .where(
          moderator_id: User.where("roles && '{#{Types::User::Roles[:version_moderator]}}'")
        )
        .sort_by(&:count)
        .reverse
    end
  end

  def video_versions_stats
    Rails.cache.fetch %i[video_versions_stats v4], expires_in: 1.day do
      Version
        .where('created_at > ?', 4.month.ago)
        .where(item_type: AnimeVideo.name)
        .group(:moderator_id)
        .select('moderator_id, count(*) as count')
        .where(
          moderator_id: User.where(
            "roles && '{#{Types::User::Roles[:video_moderator]}}'"
          )
        )
        .sort_by(&:count)
        .reverse
    end
  end

  def anime_video_reports_stats
    Rails.cache.fetch %i[anime_video_reports_stats v4], expires_in: 1.day do
      AnimeVideoReport
        .where('created_at > ?', 4.month.ago)
        .group(:approver_id)
        .select('approver_id, count(*) as count')
        .where(
          approver_id: User.where(
            "roles && '{#{Types::User::Roles[:video_moderator]}}'"
          )
        )
        .sort_by(&:count)
        .reverse
    end
  end
end
