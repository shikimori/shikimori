require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class UserProfileDecorator < UserDecorator
  instance_cache :all_compatibility, :friends, :ignored?, :stats, :nickname_changes, :clubs, :favourites

  def about_above?
    !about.blank? && !about.strip.blank? && preferences.about_on_top?
  end

  def about_below?
    !about.blank? && !about.strip.blank? && !preferences.about_on_top?
  end

  def avatar_url size=160
    super size
  end

  def website
    return '' if object.website.blank?

    url_wo_http = h.h(object.website).sub(/^https?:\/\//, '')
    h.link_to url_wo_http.sub(/\/.*/, ''), "http://#{url_wo_http}", class: 'website'
  end

  def about_html
    Rails.cache.fetch [:about, h.russian_names_key, object] do
      BbCodeFormatter.instance.format_comment about || ''
    end
  end

  def own_profile?
    h.user_signed_in? && h.current_user.id == object.id
  end

  def show_comments?
    (h.user_signed_in? || comments.any?) && preferences.comments_in_profile?
  end

  def stats
    UserStats.new object, h.current_user
  end

  def list
    UserListDecorator.new self
  end

  #def full_counts
    #if h.params[:list_type] == 'anime'
      #stats[:full_statuses][:anime].select {|v| v[:size] > 0 }
    #else
      #stats[:full_statuses][:manga].select {|v| v[:size] > 0 }
    #end
  #end

  def nickname_changes?
    nickname_changes.any?
  end

  def nickname_changes
    object
      .nickname_changes
      .select {|v| v.value != object.nickname }
  end

  def nicknames_tooltip
    "Также #{object.female? ? 'известна' : 'известен'} как: " +
      nickname_changes
        .map {|v| "<b style='white-space: nowrap'>#{h.h v.value}</b>" }
        .join("<span color='#555'>,</span> ")
  end

  # заигнорен ли пользователь текущим пользователем?
  def ignored?
    h.current_user.ignores.any? { |v| v.target_id == object.id }
  end

  def friends
    object
      .friends
      .decorate
      .sort_by {|v| v.last_online_at } # сортировка должна быть тут, а не в базе, т.к. метод last_online_at переопределён в классе
      .reverse
  end

  def common_info
    info = []

    if h.can? :access_list, self
      info << h.h(name)
      info << 'муж' if male?
      info << 'жен' if female?
      unless object.birth_on.blank?
        info << "#{full_years} #{Russian.p full_years, 'год', 'года', 'лет'}" if full_years > 9
      end
      info << location
      info << website

      info.select!(&:present?)
      info << 'Нет личных данных' if info.empty?
    else
      info << 'Личные данные скрыты'
    end

    info << "на сайте с <span class=\"reg-date\" title=\"#{localized_registration false}\">#{localized_registration true} г.</span>".html_safe

    info
  end

  def formatted_history
    history.formatted.take(anime_with_manga? ? 3 : 2)
  end

  def anime_with_manga?
    stats.anime? && stats.manga? &&
      preferences.anime_in_profile? && preferences.manga_in_profile?
  end

  def random_clubs
    clubs
      .sort_by { rand }
      .take(4)
      .sort_by(&:name)
  end

  def clubs
    object.groups.sort_by(&:name)
  end

  def compatibility klass
    all_compatibility[klass.downcase.to_sym] if all_compatibility
  end

  # текст о совместимости
  def compatibility_text klass
    number = compatibility(klass)

    if number < 5
      'нет совместимости'
    elsif number < 25
      'слабая совместимость'
    elsif number < 40
      'средняя совместимость'
    elsif number < 60
      'высокая совместимость'
    else
      'полная совместимость'
    end
  end

  # класс для контейнера текста совместимости
  def compatibility_class klass
    number = compatibility(klass)

    if number < 5
      'zero'
    elsif number < 25
      'weak'
    elsif number < 40
      'moderate'
    elsif number < 60
      'high'
    else
      'full'
    end
  end

  # добавленное пользователем в избранное
  def favourites
    (fav_animes + fav_mangas + fav_characters + fav_people)
      .shuffle# .uniq {|fav| [fav.id, fav.class] }
      .take(8)
      .sort_by do |fav|
        [fav.class.name == Manga.name ? Anime.name : fav.class.name, fav.name]
      end
  end

  # полный топик
  def main_thread
    thread = TopicProxyDecorator.new object
    thread.topic_mode!
    thread
  end

  # превью топика
  def preview_thread
    thread = TopicProxyDecorator.new object
    thread.preview_mode!
    thread
  end

  def unconnected_providers
    User.omniauth_providers.select {|v| v != :google_apps && v != :yandex } - user_tokens.map {|v| v.provider.to_sym }
  end

private

  def all_compatibility
    CompatibilityService.fetch self, h.current_user if h.user_signed_in?
  end

  def localized_registration shortened
    if !shortened
      Russian::strftime created_at, '%e %B %Y г.'

    elsif Time.zone.now - created_at < 2.months
      h.l created_at, format: :with_month_name

    elsif Time.zone.now - created_at > 2.years
      Russian::strftime created_at, '%Y'

    else# Time.zone.now - created_at > 2.months
      Russian::strftime(created_at, '%e %B %Y').sub(/^\d+ /, '')

    end
  end
end
