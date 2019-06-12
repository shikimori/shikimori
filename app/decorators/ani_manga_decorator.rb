# TODO: refactor ro view objects
class AniMangaDecorator < DbEntryDecorator
  include AniMangaDecorator::UrlHelpers
  include AniMangaDecorator::SeoHelpers

  TOPICS_PER_PAGE = 4
  NEWS_PER_PAGE = 12
  VISIBLE_RELATED = 7

  instance_cache :topics, :news_topics, :reviews, :reviews_count, :cosplay?,
    :current_rate, :changes, :versions, :versions_page,
    :roles, :related, :friend_rates, :recent_rates, :chronology,
    :rates_scores_stats, :rates_statuses_stats, :displayed_external_links

  # топики
  def topic_views
    object
      .topics
      .where(locale: h.locale_from_host)
      .where.not(updated_at: nil)
      .includes(:forum)
      .limit(TOPICS_PER_PAGE)
      .order(:updated_at)
      .map { |topic| Topics::TopicViewFactory.new(false, false).build topic }
      .map { |topic_view| format_menu_topic topic_view, :updated_at }
  end

  # число обзоров
  def reviews_count
    object.reviews.visible.count
  end

  def files?
    # anime? && !forbidden? && h.user_signed_in? &&
    anime? && h.current_user&.admin?
  end

  def art?
    imageboard_tag.present? && !forbidden?
  end

  def episode_torrents?
    anime? && h.current_user&.staff?
  end

  # есть ли обзоры
  def reviews?
    reviews_count.positive?
  end

  # есть ли косплей
  def cosplay?
    CosplayGalleriesQuery.new(object).fetch(1, 1).any?
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
    rates_query.statuses_stats.map do |k, v|
      { name: UserRate.status_name(k, object.class.name), value: v }
    end
  end

  # оценки пользователей сайта
  def rates_scores_stats
    rates_query.scores_stats.map do |k, v|
      { name: k, value: v }
    end
  end

  # последние изменения от других пользователей
  # def recent_rates limit
    # rates_query.recent_rates limit
  # end

  # полная хронология аниме
  def chronology
    Animes::ChronologyQuery.new(object).fetch.map(&:decorate)
  end

  # показывать ли ссылки, если аниме или манга для взрослых?
  def display_sensitive?
    !object.censored? && !licensed?
  end

  # есть ли видео для просмотра онлайн?
  def anime_videos?
    display_sensitive? &&
      object.respond_to?(:anime_videos) &&
      object.anime_videos.available.any?
  end

  def release_date_text # rubocop:disable all
    return unless released_on || aired_on

    parts = []

    if released?
      parts <<
        if released_on && aired_on && released_on.year != aired_on.year
          # в 2011-2012 гг.
          i18n_t(
            'datetime.release_dates.in_years',
            from_date: aired_on.year,
            to_date: released_on.year
          )
        elsif released_on && aired_on
          i18n_t(
            'datetime.release_dates.since_till_date',
            from_date: h.formatted_date(aired_on, true),
            to_date: h.formatted_date(released_on, true)
          )
        else
          i18n_t(
            'datetime.release_dates.date',
            date: h.formatted_date(released_on || aired_on, true)
          )
        end

    elsif anons?
      if aired_on
        no_fix_month = anime? && season == "winter_#{aired_on.year}"
        parts << i18n_t(
          'datetime.release_dates.for_date',
          date: h.formatted_date(aired_on, true, true, !no_fix_month)
        )
      end

    elsif aired_on && released_on # ongoings
      parts << i18n_t(
        'datetime.release_dates.since_till_date',
        from_date: h.formatted_date(aired_on, true),
        to_date: h.formatted_date(released_on, true)
      )
    else
      if aired_on
        parts << i18n_t(
          'datetime.release_dates.since_date',
          date: h.formatted_date(aired_on, true)
        )
      end
      if released_on
        parts << i18n_t(
          'datetime.release_dates.till_date',
          date: h.formatted_date(released_on, true)
        )
      end
    end

    text = parts.join(' ').html_safe

    if text.present?
      I18n.russian? ? text.downcase : text
    end
  end

  def release_date_tooltip # rubocop:disable all
    return unless released_on && aired_on
    return unless released?
    return if aired_on.year == released_on.year
    return if released_on.day == 1 && released_on.month == 1
    return if aired_on.day == 1 && aired_on.month == 1

    text = i18n_t('datetime.release_dates.since_till_date',
      from_date: h.formatted_date(aired_on, true, false),
      to_date: h.formatted_date(released_on, true, false))
    I18n.russian? ? text.capitalize : text
  end

  def displayed_external_links # rubocop:disable all
    all_links = (object.all_external_links.select(&:visible?) + (mal_id ? [mal_external_link] : []))
      .sort_by { |link| Types::ExternalLink::Source.values.index link.source.to_sym }

    (all_links.select(&:source_shikimori?) + all_links.uniq(&:label))
      .uniq(&:id)
      .sort_by { |link| Types::ExternalLink::Kind.values.index link.kind.to_sym }
  end

private

  # redefined from defaults of DbEntryDecorator
  def show_description_ru?
    h.ru_host?
  end

  def format_menu_topic topic_view, order
    {
      time: (
        topic_view.send(order) || topic_view.created_at || topic_view.updated_at
      ),
      id: topic_view.id,
      name: topic_view.topic_title,
      title: topic_view.topic_title,
      tooltip: topic_view.topic.action == AnimeHistoryAction::Episode,
      url: topic_view.urls.topic_url
    }
  end

  def rates_query
    Animes::UserRatesStatisticsQuery.new(object, h.current_user)
  end

  def mal_external_link
    @mal_external_link ||= ExternalLink.new(
      entry: object,
      kind: :myanimelist,
      source: :myanimelist,
      url: object.mal_url
    )
  end
end
