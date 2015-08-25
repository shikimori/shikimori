class DbEntryDecorator < BaseDecorator
  instance_cache :description_mal, :description_html, :main_thread, :preview_thread
  instance_cache :linked_clubs, :all_linked_clubs
  instance_cache :favoured, :favoured?, :all_favoured

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

  def show_mal_description?
    h.user_signed_in? && object.respond_to?(:description_mal) && object.description_mal.present? && description.present?
  end

  def description_html
    if description.present?
      Rails.cache.fetch [:description, h.russian_names_key, object, I18n.locale] do
        BbCodeFormatter.instance.format_description description, object
      end
    else
      description_mal
    end
  end

  def description_mal
    if object.respond_to?(:description_mal) && object.description_mal.present?
      text = BbCodeFormatter.instance
        .spoiler_to_html(object.description_mal)
        .gsub(/^\(?Source:.*/, '')
        .gsub(/\n/, "<br />")
        .strip

      text = BbCodes::PTag.instance.format(
        BbCodeFormatter.instance.paragraphs(text)
      ).html_safe

      Nokogiri::HTML::DocumentFragment
        .parse(text)
        .to_html(save_with: Nokogiri::XML::Node::SaveOptions::AS_HTML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)
        .html_safe
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
  def main_thread
    thread = TopicDecorator.new object.thread
    thread.topic_mode!
    thread
  end

  # превью топика
  def preview_thread
    thread = TopicDecorator.new object.thread
    thread.preview_mode!
    thread
  end

  # связанные клубы
  def linked_clubs
    object.groups.shuffle.take(MAX_CLUBS)
  end

  # все связанные клубы
  def all_linked_clubs
    ClubsQuery.new
      .fetch(1, 999)
      .where(id: object.groups)
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
    if I18n.russian?
      if !h.user_signed_in? || (h.user_signed_in? && !h.current_user.preferences.russian_names?)
        [name, russian].select(&:present?).compact
      else
        [russian, name].select(&:present?).compact
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
