class AniMangaDecorator < DbEntryDecorator
  include Translation
  include AniMangaDecorator::UrlHelpers
  include AniMangaDecorator::SeoHelpers

  TopicsPerPage = 4
  NewsPerPage = 12
  VISIBLE_RELATED = 7

  instance_cache :topics, :news, :reviews, :reviews_count, :comment_reviews_count, :cosplay?
  instance_cache :is_favoured, :favoured, :rate, :changes, :roles, :related
  instance_cache :friend_rates, :recent_rates, :chronology
  instance_cache :preview_reviews_thread, :main_reviews_thread
  instance_cache :rates_scores_stats, :rates_statuses_stats, :rates_size

  # топики
  def topics
    object
      .topics
      .wo_generated
      .includes(:section)
      .limit(TopicsPerPage)
      .map { |topic| format_menu_topic topic, :updated_at }
  end

  # новости
  def news
    object
      .news
      .includes(:section)
      .limit(NewsPerPage)
      .map { |topic| format_menu_topic topic, :created_at }
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

  # добавлено ли в список текущего пользователя?
  def rate
    rates.where(user_id: h.current_user.id).decorate.first if h.user_signed_in?
  end

  # основной топик
  def preview_reviews_thread
    thread = TopicDecorator.new object.thread
    thread.reviews_only! if comment_reviews?
    thread.preview_mode!
    thread
  end

  # полный топик отзывов
  def main_reviews_thread
    thread = TopicDecorator.new object.thread
    thread.reviews_only!
    thread.topic_mode!
    thread
  end

  # презентер пользовательских изменений
  def changes
    ChangesDecorator.new object
  end

  # объект с ролями аниме
  def roles
    RolesDecorator.new object
  end

  # презентер связанных аниме
  def related
    RelatedDecorator.new object
  end

  # число коментариев
  def comments_count
    thread.comments_count
  end

  # число отзывов
  def comment_reviews_count
    object.thread.comments.reviews.count
  end

  # есть ли отзывы?
  def comment_reviews?
    @comment_reviews ||= comment_reviews_count > 0
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
  def recent_rates limit
    rates_query.recent_rates limit
  end

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
        parts << i18n_t('datetime.release_dates.in_years', from_date: aired_on.year, to_date: released_on.year)
      else
        if released_on
          # 2 марта 2011
          parts << i18n_t('datetime.release_dates.date', date: h.formatted_date(released_on, true))
        else
          # с 1 марта 2011
          parts << i18n_t('datetime.release_dates.since_date', date: h.formatted_date(aired_on, true))
        end
      end

    elsif anons?
      parts << i18n_t('datetime.release_dates.for_date', date: h.formatted_date(aired_on, true)) if aired_on

    else # ongoings
      parts << i18n_t('datetime.release_dates.since_date', date: h.formatted_date(aired_on, true, true)) if aired_on
      parts << i18n_t('datetime.release_dates.till_date', date: h.formatted_date(released_on, true, true)) if released_on
    end

    parts.join(' ').html_safe if parts.any?
  end

  def release_date_tooltip
    return unless released_on && aired_on
    return if released_on.day == 1 || released_on.month == 1 || aired_on.day == 1 || aired_on.month == 1
    return unless released?

    i18n_t('datetime.release_dates.since_till_date',
      from_date: h.formatted_date(aired_on, true, false),
      to_date: h.formatted_date(released_on, true, false)
    ).capitalize
  end

private

  def format_menu_topic topic, order
    {
      date: h.time_ago_in_words(topic.send(order), i18n_t('time_ago_format')),
      id: topic.id,
      name: topic.to_s,
      title: topic.title,
      tooltip: topic.action == AnimeHistoryAction::Episode,
      url: UrlGenerator.instance.topic_url(topic)
    }
  end

  def rates_query
    UserRatesQuery.new(object, h.current_user)
  end
end
