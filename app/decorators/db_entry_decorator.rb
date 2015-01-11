class DbEntryDecorator < BaseDecorator
  instance_cache :description_mal, :description_html, :main_thread, :preview_thread
  instance_cache :favoured, :favoured?, :all_favoured

  def headline
    headline_array.join(' <span class="sep inline">/</span> ').html_safe
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
      Rails.cache.fetch [object, :description] do
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

      BbCodeFormatter.instance.paragraphs text
    else
      '<p class="b-nothing_here">Нет описания</p>'.html_safe
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

  # добавлено ли в избранное?
  def favoured?
    h.user_signed_in? && h.current_user.favoured?(object)
  end

  # добавившие в избранное
  def favoured
    FavouritesQuery.new.favoured_by object, 12
  end

  # добавившие в избранное
  def all_favoured
    FavouritesQuery.new.favoured_by object, 2000
  end

private
  def headline_array
    if !h.user_signed_in? || (h.user_signed_in? && !h.current_user.preferences.russian_names?)
      [name, russian].compact
    else
      [russian, name].compact
    end
  end

  # имя класса текущего элемента в нижнем регистре
  def klass_lower
    object.class.name.downcase
  end
end
