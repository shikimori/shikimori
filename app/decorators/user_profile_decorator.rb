require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class UserProfileDecorator < UserDecorator
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
    h.link_to url_wo_http, "http://#{url_wo_http}", class: 'website'
  end

  def own_profile?
    h.user_signed_in? && h.current_user.id == object.id
  end

  def show_comments?
    (h.user_signed_in? || comments.any?) && preferences.comments_in_profile?
  end

  def stats
    @stats ||= Rails.cache.fetch [:user, :stats, object, h.russian_genres_key] do
      UserStatisticsService.new(object, h.current_user).fetch
    end
  end

  def current_counts
    if h.params[:list_type] == 'anime'
      stats[:anime_statuses].select {|v| v[:size] > 0 }
    else
      stats[:manga_statuses].select {|v| v[:size] > 0 }
    end
  end

  def formatted_history
    history.formatted.take clubs.any? ? 3 : 4
  end

  def nickname_changes?
    nickname_changes.any?
  end

  def nickname_changes
    @nickname_changes ||= object
      .nickname_changes
      .all
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
    @ignored ||= h.current_user.ignores.any? { |v| v.target_id == object.id }
  end

  def friends
    @friends ||= object
      .friends
      .decorate
      .sort_by {|v| v.last_online_at } # сортировка должна быть тут, а не в базе, т.к. метод last_online_at переопределён в классе
      .reverse
  end

  # текст о совместимости
  def compatibility_text number
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
  def compatibility_class number
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
end

