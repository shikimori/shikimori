class AniMangaDecorator < DbEntryDecorator
  include AniMangaDecorator::UrlHelpers
  include AniMangaDecorator::SeoHelpers

  TOPICS_PER_PAGE = 4
  NEWS_PER_PAGE = 12
  VISIBLE_RELATED = 7

  instance_cache :topics, :news, :reviews, :reviews_count, :cosplay?
  instance_cache :is_favoured, :favoured, :current_rate, :changes, :versions, :versions_page
  instance_cache :roles, :related, :friend_rates, :recent_rates, :chronology
  instance_cache :rates_scores_stats, :rates_statuses_stats, :rates_size

  # топики
  def topics
    object
      .topics
      .where.not(updated_at: nil)
      .includes(:forum)
      .limit(TOPICS_PER_PAGE)
      .order(:updated_at)
      .map { |topic| Topics::TopicViewFactory.new(false, false).build topic }
      .map { |topic_view| format_menu_topic topic_view, :updated_at }
  end

  # новости
  def news
    object
      .news
      .includes(:forum)
      .limit(NEWS_PER_PAGE)
      .order(:created_at)
      .map { |topic| Topics::TopicViewFactory.new(false, false).build topic }
      .map { |topic_view| format_menu_topic topic_view, :created_at }
  end

  # число обзоров
  def reviews_count
    object.reviews.visible.count
  end

  # есть ли обзоры
  def reviews?
    reviews_count > 0
  end

  # есть ли косплей
  def cosplay?
    CosplayGalleriesQuery.new(object).fetch(1,1).any?
  end

  # аниме в списке пользователя
  def current_rate
    return unless h.user_signed_in?
    rates.where(user_id: h.current_user.id).decorate.first
  end

  # объект с ролями аниме
  def roles
    RolesQuery.new object
  end

  # презентер связанных аниме
  def related
    RelatedDecorator.new object
  end

  # оценки друзей
  def friend_rates
    if h.user_signed_in?
      rates_query.friend_rates
    else
      []
    end
  end

  # статусы пользователей сайта
  def rates_statuses_stats
    rates_query.statuses_stats.map do |k,v|
      { name: UserRate.status_name(k, object.class.name), value: v }
    end
  end

  # число оценок от пользователей сайта
  def rates_size
    Rails.cache.fetch [object, :rates], expires_in: 4.days do
      rates_statuses_stats.map {|v| v[:value] }.sum
    end
  end

  # оценки пользователей сайта
  def rates_scores_stats
    rates_query.scores_stats.map do |k,v|
      { name: k, value: v }
    end
  end

  # последние изменения от других пользователей
  # def recent_rates limit
    # rates_query.recent_rates limit
  # end

  # полная хронология аниме
  def chronology
    ChronologyQuery.new(object).fetch.map(&:decorate)
  end

  # показывать ли блок файлов
  def files?
    h.user_signed_in? && h.current_user.day_registered? &&
      anime? && !anons? && display_sensitive? && h.ignore_copyright?
  end

  # показывать ли ссылки, если аниме или манга для взрослых?
  def display_sensitive?
    !object.censored? ||
      (h.user_signed_in? && h.current_user.day_registered?)
  end

  # есть ли видео для просмотра онлайн?
  def anime_videos?
    object.respond_to?(:anime_videos) && object.anime_videos.available.any?
  end

  def release_date_text
    return unless released_on || aired_on
    parts = []

    if released?
      if released_on && aired_on && released_on.year != aired_on.year
        # в 2011-2012 гг.
        parts << i18n_t('datetime.release_dates.in_years',
          from_date: aired_on.year, to_date: released_on.year)
      elsif released_on && aired_on
        parts << i18n_t('datetime.release_dates.since_till_date',
          from_date: h.formatted_date(aired_on, true, true),
          to_date: h.formatted_date(released_on, true, true))
      else
        parts << i18n_t('datetime.release_dates.date',
          date: h.formatted_date(released_on || aired_on, true))
      end

    elsif anons?
      parts << i18n_t('datetime.release_dates.for_date',
        date: h.formatted_date(aired_on, true)) if aired_on

    else # ongoings
      if aired_on && released_on
        parts << i18n_t('datetime.release_dates.since_till_date',
          from_date: h.formatted_date(aired_on, true, true),
          to_date: h.formatted_date(released_on, true, true))
      else
        parts << i18n_t('datetime.release_dates.since_date',
          date: h.formatted_date(aired_on, true, true)) if aired_on
        parts << i18n_t('datetime.release_dates.till_date',
          date: h.formatted_date(released_on, true, true)) if released_on
      end
    end

    text = parts.join(' ').html_safe
    I18n.russian? ? text.downcase : text if text.present?
  end

  def release_date_tooltip
    return unless released_on && aired_on
    return unless released?
    return if aired_on.year == released_on.year
    return if released_on.day == 1 && released_on.month == 1
    return if aired_on.day == 1 && aired_on.month == 1

    text = i18n_t('datetime.release_dates.since_till_date',
      from_date: h.formatted_date(aired_on, true, false),
      to_date: h.formatted_date(released_on, true, false)
    )
    I18n.russian? ? text.capitalize : text
  end

private

  def format_menu_topic topic_view, order
    {
      date: h.time_ago_in_words(
        topic_view.send(order) || topic_view.created_at || topic_view.updated_at,
        i18n_t('time_ago_format')
      ),
      id: topic_view.id,
      name: topic_view.topic_title,
      title: topic_view.topic_title,
      tooltip: topic_view.topic.action == AnimeHistoryAction::Episode,
      url: topic_view.urls.topic_url
    }
  end

  def rates_query
    UserRatesQuery.new(object, h.current_user)
  end
end
