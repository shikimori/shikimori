require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class UserProfileDecorator < UserDecorator
  instance_cache :all_compatibility, :friends, :ignored?, :stats,
    :nickname_changes, :clubs, :favourites,
    :main_comments, :preview_comments, :ignored_topics

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
    Rails.cache.fetch [:about, h.russian_names_key, object.cache_key] do
      BbCodeFormatter.instance.format_comment about || ''
    end
  end

  def own_profile?
    h.user_signed_in? && h.current_user.id == object.id
  end

  def show_comments?
    (h.user_signed_in? || comments.any?) && preferences.comments_in_profile?
  end

  def list
    UserLibraryView.new self
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
    query = if h.user_signed_in? && h.current_user.moderator?
      UserNicknameChange.unscoped.where(user: object)
    else
      object.nickname_changes
    end

    query.select {|v| v.value != object.nickname }
  end

  def nicknames_tooltip
    i18n_t('aka', known: (object.female? ? 'известна' : 'известен')) + ':&nbsp;' +
      nickname_changes
        .map {|v| "<b style='white-space: nowrap'>#{h.h v.value}</b>" }
        .join("<span color='#555'>,</span> ")
  end

  # заигнорен ли пользователь текущим пользователем?
  def ignored?
    if h.user_signed_in?
      h.current_user.ignores.any? { |v| v.target_id == object.id }
    else
      false
    end
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

    info << "id: #{id}" if h.user_signed_in? && h.current_user.admin?

    if h.can? :access_list, self
      info << h.h(name)
      info << i18n_t('male') if male?
      info << i18n_t('female') if female?
      unless object.birth_on.blank?
        info << "#{full_years} #{i18n_i 'years_old', full_years}" if full_years > 12
      end
      info << location
      info << website

      info.select!(&:present?)
      info << i18n_t('no_personal_data') if info.empty?
    else
      info << i18n_t('personal_data_hidden')
    end

    info << ("#{i18n_t 'member_since'} " +
      "<span class='b-tooltipped unprocessed mobile' data-direction='right' title='#{localized_registration false}'>" +
      "#{localized_registration true}" +
      "</span>").html_safe

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
    object.clubs.sort_by(&:name)
  end

  def compatibility klass
    all_compatibility[klass.downcase.to_sym] if all_compatibility
  end

  # текст о совместимости
  def compatibility_text klass
    number = compatibility(klass)

    if number < 5
      i18n_t 'compatibility.zero'
    elsif number < 25
      i18n_t 'compatibility.low'
    elsif number < 40
      i18n_t 'compatibility.moderate'
    elsif number < 60
      i18n_t 'compatibility.high'
    else
      i18n_t 'compatibility.full'
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
      .map(&:decorate)
  end

  def main_comments
    Topics::ProxyComments.new object, false
  end

  def preview_comments
    Topics::ProxyComments.new object, true
  end

  def unconnected_providers
    User.omniauth_providers.select {|v| v != :google_apps && v != :yandex } -
      user_tokens.map {|v| v.provider.to_sym }
  end

  def ignored_topics
    object.topic_ignores.includes(:topic).map do |topic_ignore|
      Topics::Factory.new(false, false).build topic_ignore.topic
    end
  end

private

  def all_compatibility
    CompatibilityService.fetch self, h.current_user if h.user_signed_in?
  end

  def localized_registration shortened
    if created_at > 2.months.ago || !shortened
      h.l created_at, format: i18n_t('registration_formats.full')

    elsif created_at > 2.years.ago
      h.l(
        created_at, format: i18n_t('registration_formats.month_year')
      ).sub(/^\d+ /, '') # замена делается т.к. в русском варианте
      # если брать перевод даты без %d, то месяц будет в неправильном падеже

    else
      h.l created_at, format: i18n_t('registration_formats.year')
    end
  end
end
