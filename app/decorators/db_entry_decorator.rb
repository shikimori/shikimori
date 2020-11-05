class DbEntryDecorator < BaseDecorator # rubocop:disable ClassLength
  include VersionedConcern

  instance_cache :description_html,
    :menu_clubs, :all_clubs, :collections_size, :menu_collections,
    :contest_winners,
    :favoured, :favoured?, :all_favoured, :favoured_size,
    :main_topic_view, :preview_topic_view,
    :parameterized_versions

  MAX_CLUBS = 4
  MAX_COLLECTIONS = 3
  MAX_FAVOURITES = 12

  CACHE_VERSION = :v11

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
    html = Rails.cache.fetch CacheHelper.keys(:description_html_ru, object, CACHE_VERSION) do
      BbCodes::EntryText.call description_ru.text, entry: object, lang: :ru
    end

    html.presence || "<p class='b-nothing_here'>#{i18n_t 'no_description'}</p>".html_safe
  end

  def description_html_en
    html = Rails.cache.fetch CacheHelper.keys(:descrption_html_en, object) do
      BbCodes::Text.call description_en.text, lang: :en
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
      object.maybe_topic(h.locale_from_host)
    )
  end

  def preview_topic_view
    Topics::TopicViewFactory.new(true, false).build(
      object.maybe_topic(h.locale_from_host)
    )
  end

  def menu_clubs
    clubs_scope.shuffle.take(MAX_CLUBS)
  end

  def all_clubs
    Clubs::Query.fetch(h.user_signed_in?, h.locale_from_host)
      .where(id: clubs_scope)
      .decorate
  end

  def clubs_scope
    scope = object.clubs.where(lang: h.locale_from_host)
    scope.where! is_censored: false if !object.try(:censored?) && h.censored_forbidden?
    scope
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
      .where(lang: h.locale_from_host)
  end

  def favoured?
    h.user_signed_in? && h.current_user.favoured?(object)
  end

  def favoured
    FavouritesQuery.new.favoured_by object, MAX_FAVOURITES
  end

  def all_favoured
    FavouritesQuery.new.favoured_by object, 816
  end

  def favoured_size
    FavouritesQuery.new.favoured_size object
  end

  def authors field
    @authors ||= {}
    @authors[field] ||= versions_scope.authors(field)
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

  def merge_url
    h.send "merge_#{klass_lower}_url"
  end

private

  def versions_scope
    if h.params[:video_id]
      super.where(item_id: h.params[:video_id], item_type: Video.name)
    else
      super
    end
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
end
