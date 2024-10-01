# TODO: refactor ro view objects
class AniMangaDecorator < DbEntryDecorator
  include AniMangaDecorator::UrlHelpers
  include AniMangaDecorator::SeoHelpers
  include AniMangaDecorator::PosterHelpers

  TOPICS_PER_PAGE = 4
  VISIBLE_RELATED = 7

  instance_cache :news_topics, :critiques_count, :reviews_count, :cosplay?,
    :current_rate, :changes, :versions, :versions_page,
    :roles, :related, :friend_rates, :recent_rates, :chronology,
    :genres_v2_wo_themes, :genres_v2_themes,
    :external_links, :available_external_links,
    :watch_online_external_links, :menu_external_links,
    :topic_views

  def topic_views
    object
      .topics
      .where.not(updated_at: nil)
      .includes(:forum)
      .limit(TOPICS_PER_PAGE)
      .order(:updated_at)
      .map do |topic|
        format_menu_topic(
          Topics::TopicViewFactory.new(false, false).build(topic),
          :updated_at
        )
      end
  end

  def critiques_count
    object.critiques.visible.count
  end

  def reviews_count
    object.reviews.count
  end

  def files?
    # anime? && !forbidden? && h.user_signed_in? &&
    anime? && h.current_user&.admin?
  end

  def art?
    Shikimori::IS_IMAGEBOARD_TAGS_ENABLED &&
      imageboard_tag.present? && !forbidden?
  end

  def episode_torrents?
    anime? && h.current_user&.staff?
  end

  def critiques?
    critiques_count.positive?
  end

  def cosplay?
    CosplayGalleriesQuery.new(object).fetch(1, 1).any?
  end

  def current_rate
    return unless h.user_signed_in?

    rates.where(user_id: h.current_user.id).first
  end

  # def genres_v2_sorted
  #   object.genres_v2.sort_by { |v| [v.position, v.russian] }
  # end

  def genres_v2_wo_themes
    object.genres_v2.reject(&:theme?)
  end

  def genres_v2_themes
    object.genres_v2.select(&:theme?)
  end

  def roles
    RolesQuery.new object
  end

  def related
    RelatedDecorator.new object
  end

  def friend_rates
    if h.user_signed_in?
      rates_query.friend_rates
    else
      []
    end
  end

  def chronology
    Animes::ChronologyQuery.new(object).fetch.map(&:decorate)
  end

  def release_date_text # rubocop:disable all
    return unless released_on.present? || aired_on.present?

    parts = []

    if released?
      parts <<
        if released_on.present? && aired_on.present? && released_on.year != aired_on.year
          # в 2011-2012 гг.
          i18n_t(
            'datetime.release_dates.in_years',
            from_date: aired_on.year,
            to_date: released_on.year
          )
        elsif released_on.present? && aired_on.present?
          i18n_t(
            'datetime.release_dates.since_till_date',
            from_date: aired_on.human(true),
            to_date: released_on.human(true)
          )
        else
          i18n_t(
            'datetime.release_dates.date',
            date: (released_on.presence || aired_on).human(true)
          )
        end

    elsif anons?
      if aired_on.present?
        parts << i18n_t(
          'datetime.release_dates.for_date',
          date: aired_on.human(true)
        )
      end

    elsif aired_on.present? && released_on.present? # ongoings
      parts << i18n_t(
        'datetime.release_dates.since_till_date',
        from_date: aired_on.human(true),
        to_date: released_on.human(true)
      )
    else
      if aired_on.present?
        parts << i18n_t(
          'datetime.release_dates.since_date',
          date: aired_on.human(true)
        )
      end
      if released_on.present?
        parts << i18n_t(
          'datetime.release_dates.till_date',
          date: released_on.human(true)
        )
      end
    end

    text = parts.join(' ').html_safe

    if text.present?
      I18n.russian? ? text.downcase : text
    end
  end

  def release_date_tooltip
    return unless released_on.present? && aired_on.present? && released?
    return if aired_on.uncertain? && released_on.uncertain?

    text = i18n_t 'datetime.release_dates.since_till_date',
      from_date: aired_on.human(false),
      to_date: released_on.human(false)

    I18n.russian? ? text.capitalize : text
  end

  def external_links
    object.external_links.sort_by do |link|
      Types::ExternalLink::Kind.values.index link.kind.to_sym
    end
  end

  def watch_online_external_links
    available_external_links.select(&:watch_online?)
  end

  def menu_external_links
    available_external_links.reject(&:watch_online?)
  end

  def available_external_links # rubocop:disable all
    return [] if rkn_abused?

    all_links = (object.all_external_links.select(&:visible?) + (mal_id ? [mal_external_link] : []))
      .sort_by { |link| Types::ExternalLink::Source.values.index link.source.to_sym }

    (all_links.select(&:source_shikimori?) + all_links.uniq(&:label))
      .uniq(&:id)
      .reject(&:disabled?)
      .sort_by { |link| Types::ExternalLink::Kind.values.index link.kind.to_sym }
  end

  def more_info?
    object.more_info.present? && !object.more_info.ends_with?('[MAL]')
  end

  def more_info_html
    h.h(object.more_info).gsub("\n", '<br>').html_safe
  end

private

  def format_menu_topic topic_view, order
    {
      time: topic_view.send(order) || topic_view.created_at ||
        topic_view.updated_at,
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
