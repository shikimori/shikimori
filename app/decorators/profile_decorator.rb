class ProfileDecorator < UserDecorator
  def about_above?
    !about.blank? && !about.strip.blank? && preferences.about_on_top?
  end

  def about_below?
    !about.blank? && !about.strip.blank? && !preferences.about_on_top?
  end

  def avatar
    h.gravatar_url object, 160
  end

  def website
    return if object.website.blank?

    url_wo_http = h.h(object.website).sub(/^https?:\/\//, '')
    h.link_to url_wo_http, "http://#{url_wo_http}", class: 'website'
  end

  def clubs
    @clubs ||= if preferences.clubs_in_profile?
      object.groups.order(:name).limit 4
    else
      []
    end
  end

  def own_profile?
    h.user_signed_in? && h.current_user.id == object.id
  end

  def show_comments?
    (h.user_signed_in? || comments.any?) && preferences.comments_in_profile?
  end

  def history
    @history ||= ProfileHistoryDecorator.new(object, clubs.any? ? 3 : 4)
  end

  def stats
    cache_key = Digest::MD5.hexdigest "user_stats_#{object.cache_key}_#{!h.current_user || (h.current_user && h.current_user.preferences.russian_genres?) ? 'rus' : 'en'}"
    @stats ||= Rails.cache.fetch cache_key do
      UserStatisticsService.new(object, h.current_user).fetch
    end
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
end
