class UserDecorator < BaseDecorator
  instance_cache :clubs_wo_shadowbanned, :exact_last_online_at,
    :is_friended?, :mutual_friended?, :list_stats, :activity_stats, :club_ids

  CACHE_VERSION = :v2

  def self.model_name
    User.model_name
  end

  def clubs_wo_shadowbanned
    Clubs::Query.new(object.clubs)
      .without_shadowbanned(h.current_user)
      .decorate
      .sort_by(&:name)
  end

  def url
    h.profile_url(
      will_save_change_to_nickname? ? to_param(changes['nickname'][0]) : self
    )
  end

  def edit_url section:
    h.edit_profile_url(
      will_save_change_to_nickname? ? to_param(changes['nickname'][0]) : self,
      section: section
    )
  end

  def show_contest_link?
    (can_vote_1? || can_vote_2? || can_vote_3?) &&
      notification_settings_contest_event?
  end

  def unvoted_contests
    [
      can_vote_1?,
      can_vote_2?,
      can_vote_3?
    ].count { |v| v }
  end

  def is_friended?
    h.current_user&.friend_links&.any? { |v| v.dst_id == id }
  end

  def mutual_friended?
    is_friended? && friended?(h.current_user)
  end

  def list_stats
    cache_key = [
      :list_stats,
      object.cache_key,
      object.rate_at || object.updated_at,
      object.preferences.statistics_start_on,
      CACHE_VERSION
    ]

    Profiles::ListStatsView.new(
      Rails.cache.fetch(cache_key) { Users::ListStatsQuery.call object }
    )
  end

  def activity_stats
    cache_key = [
      :activity_stats,
      object.cache_key,
      object.activity_at || object.updated_at,
      CACHE_VERSION
    ]

    Rails.cache.fetch cache_key do
      Users::ActivityStatsQuery.call object
    end
  end

  def exact_last_online_at
    return Time.zone.now if new_record?

    cached = ::Rails.cache.read last_online_cache_key
    cached = Time.zone.parse cached if cached

    [
      cached,
      last_online_at,
      current_sign_in_at,
      created_at
    ].compact.max
  end

  def last_online
    if object.admin?
      i18n_t 'always_online'
    elsif object.bot?
      i18n_t 'always_online_bot'
    elsif Time.zone.now - 5.minutes <= exact_last_online_at || object.id == User::GUEST_ID
      i18n_t 'online'
    else
      i18n_t 'offline',
        time_ago: h.time_ago_in_words(exact_last_online_at),
        ago: (" #{i18n_t 'ago'}" if exact_last_online_at > 1.day.ago)
    end
  end

  def unread_messages_url
    if unread.messages.positive? ||
        (unread.news.zero? && unread.notifications.zero?)
      h.profile_dialogs_url object
    elsif unread.news.positive?
      h.index_profile_messages_url object, messages_type: :news
    else
      h.index_profile_messages_url object, messages_type: :notifications
    end
  end

  def club_ids
    @club_ids ||= association_cached?(:club_roles) ?
      club_roles.map(&:club_id) :
      club_roles.pluck(:club_id)
  end

  # def avatar_url size, ignore_censored = false
  #   if !ignore_censored && censored_avatar?
  #     format(
  #       'https://www.gravatar.com/avatar/%s?s=%i&d=identicon',
  #       Digest::MD5.hexdigest('takandar+censored@gmail.com'),
  #       size
  #     )
  #   else
  #     # "https://www.gravatar.com/avatar/%s?s=%i&d=identicon" % [Digest::MD5.hexdigest(email.downcase), size]
  #     ImageUrlGenerator.instance.cdn_image_url object, "x#{size}".to_sym
  #   end
  # end
end