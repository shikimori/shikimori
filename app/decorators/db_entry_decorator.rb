class DbEntryDecorator < BaseDecorator
  instance_cache :description_html
  instance_cache :linked_clubs, :all_linked_clubs
  instance_cache :favoured, :favoured?, :all_favoured
  instance_cache :main_topic_view, :preview_topic_view

  MAX_CLUBS = 4
  MAX_FAVOURITES = 12

  def headline
    headline_array
      .map { |name| h.h name }
      .join(' <span class="sep inline">/</span> ')
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
    DbEntries::Description.from_value(object.description_ru)
  end

  def description_en
    DbEntries::Description.from_value(object.description_en)
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
    html = Rails.cache.fetch [:description_html_ru, object] do
      BbCodeFormatter.instance.format_description(description_ru.text, object)
    end

    if html.blank?
      "<p class='b-nothing_here'>#{i18n_t('no_description')}</p>".html_safe
    else
      html
    end
  end

  def description_html_en
    html = Rails.cache.fetch [:descrption_html_en, object] do
      BbCodeFormatter.instance.format_comment(description_en.text)
    end

    if html.blank?
      "<p class='b-nothing_here'>#{i18n_t('no_description')}</p>".html_safe
    else
      html
    end
  end

  def description_html_truncated length = 150
    h.truncate_html(
      description_html,
      length: length,
      separator: ' ',
      word_boundary: /\S[\.\?\!<>]/
    ).html_safe
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

  # связанные клубы
  def linked_clubs
    query = clubs_for_domain
    if !object.try(:censored?) && h.censored_forbidden?
      query = query.where(is_censored: false)
    end
    query.decorate.shuffle.take(MAX_CLUBS)
  end

  # все связанные клубы
  def all_linked_clubs
    query = ClubsQuery
      .new(h.locale_from_host)
      .query(true)
      .where(id: clubs_for_domain)

    if !object.try(:censored?) && h.censored_forbidden?
      query = query.where(is_censored: false)
    end

    query.decorate
  end

  # добавлено ли в избранное?
  def favoured?
    h.user_signed_in? && h.current_user.favoured?(object)
  end

  # добавившие в избранное
  def favoured
    FavouritesQuery.new.favoured_by object, MAX_FAVOURITES
  end

  # добавившие в избранное
  def all_favoured
    FavouritesQuery.new.favoured_by object, 2000
  end

  def versions
    VersionsQuery.new object
  end

  def versions_page
    versions.postload (h.params[:page] || 1).to_i, 15
  end

  def path
    h.send "#{klass_lower}_url", object
  end

  def url subdomain=true
    h.send "#{klass_lower}_url", object, subdomain: subdomain
  end

  def edit_url
    h.send "edit_#{klass_lower}_url", object
  end

  def edit_field_url field
    h.send "edit_field_#{klass_lower}_url", object, field: field
  end

  def comments_url
    topic = object.maybe_topic h.locale_from_host
    UrlGenerator.instance.topic_url(topic) if topic
  end

  def next_versions_page
    h.send "versions_#{klass_lower}_url", object,
      page: (h.params[:page] || 1).to_i + 1
  end

  private

  def show_description_ru?
    h.ru_host?
  end

  def clubs_for_domain
    object.clubs.where(locale: h.locale_from_host)
  end

  def headline_array
    if h.ru_host?
      if !h.user_signed_in? || (I18n.russian? && h.current_user.preferences.russian_names?)
        [russian, name].select(&:present?).compact
      else
        [name, russian].select(&:present?).compact
      end

    else
      [name]
    end
  end

  # имя класса текущего элемента в нижнем регистре
  def klass_lower
    if respond_to?(:anime?) && anime?
      Anime.name.downcase
    elsif respond_to?(:manga?) && manga?
      Manga.name.downcase
    else
      object.class.name.downcase
    end
  end
end
