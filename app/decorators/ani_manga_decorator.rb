class AniMangaDecorator < DbEntryDecorator
  include AniMangaDecorator::UrlHelpers
  include AniMangaDecorator::SeoHelpers

  TopicsPerPage = 4
  NewsPerPage = 12
  VISIBLE_RELATED = 7

  instance_cache :topics, :news, :reviews, :reviews_count, :summaries_count, :cosplay?
  instance_cache :is_favoured, :favoured, :current_rate, :changes, :versions, :versions_page
  instance_cache :roles, :related, :friend_rates, :recent_rates, :chronology
  instance_cache :preview_summaries_thread, :main_summaries_thread
  instance_cache :rates_scores_stats, :rates_statuses_stats, :rates_size

  # топики
  def topics
    object
      .topics
      .wo_empty_generated
      .includes(:forum)
      .limit(TopicsPerPage)
      .order(:updated_at)
      .map { |topic| format_menu_topic topic, :updated_at }
  end

  # новости
  def news
    object
      .news
      .includes(:forum)
      .limit(NewsPerPage)
      .order(:created_at)
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

  # анмие в списке пользователя
  def current_rate
    rates.where(user_id: h.current_user.id).decorate.first if h.user_signed_in?
  end

  # основной топик
  def preview_summaries_thread
    summaries_view true
  end

  # полный топик отзывов
  def main_summaries_thread
    summaries_view false
  end

  # объект с ролями аниме
  def roles
    RolesQuery.new object
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
  def summaries_count
    @summaries_count ||= object.thread.comments.summaries.count
  end

  # есть ли отзывы?
  def summaries?
    summaries_count > 0
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
    ApplyRatedEntries.new(h.current_user).call(
      ChronologyQuery.new(object).fetch.map(&:decorate)
    )
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
    return if released_on.day == 1 || released_on.month == 1 || aired_on.day == 1 || aired_on.month == 1
    return unless released?

    text = i18n_t('datetime.release_dates.since_till_date',
      from_date: h.formatted_date(aired_on, true, false),
      to_date: h.formatted_date(released_on, true, false)
    )
    I18n.russian? ? text.capitalize : text
  end

private

  def format_menu_topic topic, order
    {
      date: h.time_ago_in_words(topic.send(order), i18n_t('time_ago_format')),
      id: topic.id,
      #name: topic.to_s,
      name: topic.to_s,
      title: topic.title,
      tooltip: topic.action == AnimeHistoryAction::Episode,
      url: UrlGenerator.instance.topic_url(topic)
    }
  end

  def rates_query
    UserRatesQuery.new(object, h.current_user)
  end

  def summaries_view is_preview
    view = Topics::Factory.new(is_preview, false).build thread
    view.comments.summary_new_comment = true
    view.comments.summaries_query = summaries?
    view
  end
end
