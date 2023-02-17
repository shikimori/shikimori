class ModerationsController < ShikimoriController # rubocop:disable ClassLength
  include SidekiqPaginatorConcern

  AUTOCOMPLETE_LIMIT = 10

  before_action :authenticate_user!
  helper_method :moderation_policy

  before_action do
    breadcrumb i18n_t('title'), moderations_url
    og page_title: i18n_t('title')
  end

  def show # rubocop:disable all
    @clubs = [
      (StickyClubView.content_moderation unless Rails.env.test?),
      (StickyClubView.forum_moderation unless Rails.env.test?)
    ].compact

    if can? :manage_forum_moderator_role, User
      @abuse_requests_stats = abuse_requests_stats
      @bans_stats = bans_stats
    end

    if can? :manage_version_moderator_role, User
      @content_versions_stats = content_versions_stats
    end

    if can? :manage_critique_moderator_role, User
      @critiques_stats = critiques_stats
    end

    if can? :manage_collection_moderator_role, User
      @collections_stats = collections_stats
    end

    if can? :manage_article_moderator_role, User
      @articles_stats = articles_stats
    end

    if can? :sync, Anime
      @proxies_alive_count = Proxy.alive.count
      @proxies_total_count = Proxy.count

      @enqueued_limit = 100
      @sidkiq_enqueued = Sidekiq::Queue
        .all
        .select { |queue| queue.name == 'mal_parsers' }
        .map { |queue| sidekiq_page "queue:#{queue.name}", queue.name, @enqueued_limit }
        .map(&:third)
        .flatten
        .map do |v|
          job = JSON.parse v
          job['enqueued_at'] = Time.zone.at(job['enqueued_at'])
          job
        end
        .select { |v| v['class'].match?(/MalParsers/) }
        .sort_by { |v| v['enqueued_at'] }

      @sidkiq_busy = Sidekiq::Workers.new
        .to_a
        .map { |v| v[2]['payload'] }
        .select { |v| v['class'].match?(/MalParsers/) }
        .map do |job|
          job['enqueued_at'] = Time.zone.at(job['enqueued_at'])
          job
        end
        .select { |v| v['class'].match?(/MalParsers/) }
        .sort_by { |v| v['enqueued_at'] }
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
                #{Types::User::Roles[:version_names_moderator]},
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

  def critiques_stats
    Rails.cache.fetch %i[critiques_stats v4], expires_in: 1.day do
      Critique
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

  def articles_stats
    Rails.cache.fetch %i[article_stats v1], expires_in: 1.day do
      Article
        .where('created_at > ?', 4.month.ago)
        .where.not(moderation_state: :pending)
        .where.not(approver_id: nil)
        .group(:approver_id)
        .select('approver_id, count(*) as count')
        .sort_by(&:count)
        .reverse
    end
  end

  def moderation_policy
    @moderation_policy ||= ModerationPolicy.new(
      current_user,
      false
    )
  end
end
