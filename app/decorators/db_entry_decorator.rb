class DbEntryDecorator < BaseDecorator # rubocop:disable ClassLength
  include VersionedConcern

  instance_cache :description_html,
    :menu_clubs, :all_clubs, :collections_size, :menu_collections,
    :contest_winners,
    :favoured, :favoured?, :all_favoured, :favoured_size,
    :main_topic_view, :preview_topic_view,
    :parameterized_versions,
    :news_topic_views

  MAX_CLUBS = 4
  MAX_COLLECTIONS = 3
  MAX_FAVOURITES = 12
  MAX_NEWS = 12

  CACHE_VERSION = :v1

  def headline
    headline_array
      .map { |name| h.h name }
      .join(' <span class="b-separator inline">/</span> ')
      .html_safe
  end

  #----------------------------------------------------------------------------

  # description object is used to get text (bbcode) or source
  # (e.g. used when editing description)
  def description
    if show_description_ru?
      description_ru
    else
      description_en
    end
  end

  def description_ru
    DbEntries::Description.from_value object.description_ru

    # DbEntries::Description.from_value(
    #   object.description_ru.present? ?
    #     object.description_ru :
    #     object.description_en
    # )
  end

  def description_en
    DbEntries::Description.from_value object.description_en

    # DbEntries::Description.from_value(
    #   object.description_en.present? ?
    #     object.description_en :
    #     object.description_ru
    # )
  end

  #----------------------------------------------------------------------------

  # description text (bbcode) formatted as html
  # (displayed on specific anime main page)
  def description_html
    if show_description_ru?
      description_html_ru
    else
      description_html_en
    end
  end

  def description_html_ru
    text = description_ru.text
    cache_key = CacheHelperInstance.cache_keys(
      object.cache_key,
      XXhash.xxh32(text),
      CACHE_VERSION
    )

    html = Rails.cache.fetch cache_key do
      BbCodes::EntryText.call text, entry: object, lang: :ru
    end

    html.presence || "<p class='b-nothing_here'>#{i18n_t 'no_description'}</p>".html_safe
  end

  def description_html_en
    text = description_en.text
    cache_key = CacheHelperInstance.cache_keys(
      object.cache_key,
      XXhash.xxh32(text),
      CACHE_VERSION
    )

    html = Rails.cache.fetch cache_key do
      BbCodes::EntryText.call text, lang: :en
    end

    html.presence || "<p class='b-nothing_here'>#{i18n_t('no_description')}</p>".html_safe
  end

  def description_html_truncated length = 150
    h.truncate_html(
      description_html,
      length: length,
      separator: ' ',
      word_boundary: /\S[.?!<>]/
    ).html_safe
  end

  def description_meta
    h.truncate(
      description_html.gsub(%r{<br ?/?>}, "\n").gsub(/<.*?>/, ''),
      length: 250,
      separator: ' ',
      word_boundary: /\S[.?!<>]/
    )
  end

  #----------------------------------------------------------------------------

  def main_topic_view
    Topics::TopicViewFactory.new(false, false).build(
      object.maybe_topic
    )
  end

  def preview_topic_view
    Topics::TopicViewFactory.new(true, false).build(
      object.maybe_topic
    )
  end

  def menu_clubs
    clubs_scope.shuffle.take(MAX_CLUBS)
  end

  def all_clubs
    clubs_scope.decorate
  end

  def clubs_scope
    return Club.none if respond_to?(:rkn_abused?) && rkn_abused?

    scope = Clubs::Query.fetch(h.current_user, false, object.clubs)
    scope = scope.where is_censored: false if !object.try(:censored?) && h.censored_forbidden?
    scope
  end

  def clubs_scope_cache_key
    clubs_scope
      .except(:order)
      .pick(Arel.sql('count(*), max(clubs.updated_at)'))
      .join('/')
  end

  def menu_collections
    collections_scope
      .uniq
      .shuffle
      .take(MAX_COLLECTIONS)
      .sort_by(&:name)
  end

  def collections_size
    collection_links
      .joins(:collection)
      .merge(Collection.available)
      .select('count(distinct(collection_id))')[0].count
  end

  def collections_scope
    object.collections.available
  end

  def favourites_scope
    favourites_query.scope object
  end

  def news_topic_scope
    object.news_topics
  end

  def news_topic_views
    return [] if respond_to?(:rkn_abused?) && rkn_abused?

    news_topic_scope
      .includes(:forum)
      .limit(MAX_NEWS)
      .order(:created_at)
      .map do |topic|
        format_menu_topic(
          Topics::TopicViewFactory.new(false, false).build(topic),
          :created_at
        )
      end
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

  def favoured?
    h.user_signed_in? && h.current_user.favoured?(object)
  end

  def favoured
    favourites_query.favoured_by object, MAX_FAVOURITES
  end

  def all_favoured
    favourites_query.favoured_by object, 816
  end

  def favoured_size
    favourites_query.favoured_size object
  end

  def authors field
    @authors ||= {}
    @authors[field] ||= versions_scope
      .except(:includes)
      .authors(field)
  end

  def contest_winners
    object.contest_winners
      .where('position <= 16')
      .includes(:contest)
      .order(:position, id: :desc)
  end

  def path
    h.send "#{klass_lower}_url", object
  end

  def url subdomain = true
    h.send "#{klass_lower}_url", object, subdomain: subdomain
  end

  def edit_url
    h.send "edit_#{klass_lower}_url", object
  end

  def edit_field_url field
    h.send "edit_field_#{klass_lower}_url", object, field: field
  end

  def versions_url page
    h.send "versions_#{klass_lower}_url", object, page: page
  end

  def sync_url
    h.send "sync_#{klass_lower}_url"
  end

  def refresh_poster_url
    h.send "refresh_poster_#{klass_lower}_url"
  end

  def refresh_stats_url
    h.send "refresh_stats_#{klass_lower}_url"
  end

  def merge_into_other_url
    h.send "merge_into_other_#{klass_lower}_url"
  end

  def merge_as_episode_url
    h.send "merge_as_episode_#{klass_lower}_url"
  end

private

  def versions_scope
    scope = super

    if h.params[:video_id]
      scope = scope.where item_id: h.params[:video_id], item_type: Video.name
    end

    scope
  end

  def show_description_ru?
    I18n.russian?
  end

  def headline_array
    if h.ru_host?
      if russian_names?
        [russian, name].select(&:present?).compact
      else
        [name, russian].select(&:present?).compact
      end

    else
      [name]
    end
  end

  def klass_lower # rubocop:disable AbcSize
    if object.is_a? Character # because character has method :anime?
      Character.name.downcase

    elsif object.is_a? Person
      Person.name.downcase

    elsif respond_to?(:anime?) && anime?
      Anime.name.downcase

    elsif respond_to?(:manga?) && manga?
      Manga.name.downcase

    else
      object.class.name.downcase
    end
  end

  def russian_names?
    !h.user_signed_in? || (
      I18n.russian? &&
      h.current_user.preferences.russian_names?
    )
  end

  def favourites_query
    @favouries_query ||= FavouritesQuery.new
  end
end
