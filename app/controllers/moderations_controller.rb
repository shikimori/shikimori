class ModerationsController < ShikimoriController
  before_action :authenticate_user!

  before_action do
    breadcrumb i18n_t('title'), moderations_url
    og page_title: i18n_t('title')
  end

  def show # rubocop:disable All
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

    if can? :manage_review_moderator_role, User
      @reviews_stats = reviews_stats
    end

    if can? :manage_collection_moderator_role, User
      @collections_stats = collections_stats
    end
  end

  def missing_screenshots
    og page_title: i18n_t('missing_screenshots_title')

    @collection = Rails.cache.fetch :missing_screenshots, expires_in: 1.hour do
      Moderation::MissingScreenshotsQuery.new.fetch
    end
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
          moderator_id: User.where(
            <<~ROLES.squish
              roles && '{
                #{Types::User::Roles[:version_texts_moderator]},
                #{Types::User::Roles[:version_moderator]},
                #{Types::User::Roles[:version_fansub_moderator]}
              }'
            ROLES
          )
        )
        .sort_by(&:count)
        .reverse
    end
  end

  def reviews_stats
    Rails.cache.fetch %i[reviews_stats v4], expires_in: 1.day do
      Review
        .where('created_at > ?', 4.month.ago)
        .where.not(moderation_state: :pending)
        .where.not(approver_id: nil)
        .group(:approver_id)
        .select('approver_id, count(*) as count')
        .sort_by(&:count)
        .reverse
    end
  end

  def collections_stats
    Rails.cache.fetch %i[collection_stats v4], expires_in: 1.day do
      Collection
        .where('created_at > ?', 4.month.ago)
        .where.not(moderation_state: :pending)
        .where.not(approver_id: nil)
        .group(:approver_id)
        .select('approver_id, count(*) as count')
        .sort_by(&:count)
        .reverse
    end
  end
end
