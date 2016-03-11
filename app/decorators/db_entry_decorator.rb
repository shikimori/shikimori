class DbEntryDecorator < BaseDecorator
  instance_cache :description_ru, :description_en, :description_html,
    :main_topic_view, :preview_topic_view, :linked_clubs, :all_linked_clubs,
    :favoured, :favoured?, :all_favoured

  MAX_CLUBS = 4
  MAX_FAVOURITES = 12

  def headline
    headline_array
      .map { |name| h.h name }
      .join(' <span class="sep inline">/</span> ')
      .html_safe
  end

  # хак, т.к. source переопределяется в декораторе
  def source
    object.source
  end

  def description_en?
    object.description_en.present?
  end

  def description_ru?
    h.ru_domain? && object.description_ru.present?
  end

  def description_html
    if description_ru?
      description_ru
    else
      description_en
    end
  end

  def description_ru
    Rails.cache.fetch [:descrption, h.russian_names_key, object, I18n.locale] do
      BbCodeFormatter.instance.format_description object.description_ru, object
    end
  end

  def description_en
    if object.respond_to?(:description_en) && object.description_en.present?
      Rails.cache.fetch [:descrption_en, h.russian_names_key, object, I18n.locale] do
        BbCodeFormatter.instance.format_comment object.description_en
      end
    else
      "<p class='b-nothing_here'>#{i18n_t 'no_description'}</p>".html_safe
    end
  end

  def description_html_truncated length=150
    h.truncate_html(
      description_html,
      length: length, separator: ' ', word_boundary: /\S[\.\?\!<>]/
    ).html_safe
  end

  # адрес на mal'е
  def mal_url
    "http://myanimelist.net/#{klass_lower}/#{object.id}"
  end

  # полный топик
  def main_topic_view
    Topics::TopicViewFactory.new(false, false).build topic
  end

  # превью топика
  def preview_topic_view
    Topics::TopicViewFactory.new(true, false).build topic
  end

  # связанные клубы
  def linked_clubs
    query = object.clubs
    query = query.where(is_censored: false) unless object.try :censored?
    query.shuffle.take(MAX_CLUBS)
  end

  # все связанные клубы
  def all_linked_clubs
    ClubsQuery.new.query
      .where(id: object.clubs)
      .where(is_censored: false)
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

  def url subdomain=true
    h.send "#{klass_lower}_url", object, subdomain: subdomain
  end

  def edit_url
    h.send "edit_#{klass_lower}_url", object
  end

  def edit_field_url field
    h.send "edit_field_#{klass_lower}_url", object, field: field
  end

  def next_versions_page
    h.send "versions_#{klass_lower}_url", object, page: (h.params[:page] || 1).to_i + 1
  end

private

  def headline_array
    if h.ru_domain?
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
