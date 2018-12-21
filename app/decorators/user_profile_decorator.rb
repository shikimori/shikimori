# TODO: refactor to view object
class UserProfileDecorator < UserDecorator
  instance_cache :all_compatibility, :friends, :ignored?, :stats,
    :nickname_changes, :favorites,
    :main_comments_view, :preview_comments_view, :ignored_topics,
    :random_clubs

  # list of users with abusive content in profile
  # (reported by moderators or roskomnadzor)
  BANNED_PROFILES = %w[7683]

  def banned_profile?
    BANNED_PROFILES.include? object.id.to_s
  end

  def website
    return '' if website_host.blank?

    h.link_to h.h(website_host), h.h(website_url), class: 'website'
  end

  def about_html
    return if banned_profile?

    Rails.cache.fetch [:about, object] do
      BbCodes::Text.call about || ''
    end
  end

  def show_comments?
    !banned_profile? &&
      (h.user_signed_in? || comments.any?) && preferences.comments_in_profile?
  end

  # def full_counts
  #   if h.params[:list_type] == 'anime'
  #     stats[:full_statuses][:anime].select {|v| v[:size] > 0 }
  #   else
  #     stats[:full_statuses][:manga].select {|v| v[:size] > 0 }
  #   end
  # end

  def nickname_changes?
    nickname_changes.any?
  end

  def nickname_changes
    query =
      if h.can? :manage, Ban
        UserNicknameChange.unscoped.where(user: object)
      else
        object.nickname_changes
      end

    query.reject { |v| v.value == object.nickname }
  end

  def nicknames_tooltip
    i18n_t('aka', known: (object.female? ? 'известна' : 'известен')) + ':&nbsp;' +
      nickname_changes
        .map { |v| "<b style='white-space: nowrap'>#{h.h v.value}</b>" }
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
    object.friends.order(last_online_at: :desc)
  end

  def common_info
    info = []

    info << "id: #{id}" if h.user_signed_in? && h.current_user.admin?

    if h.can? :access_list, self
      info << h.h(name)
      unless object.sex.blank?
        info << i18n_t('male') if male?
        info << i18n_t('female') if female?
      end
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

    info << "#{i18n_t 'member_since'} " \
      "<span class='b-tooltipped unprocessed mobile' data-direction='right' "\
      "title='#{localized_registration false}'>#{localized_registration true}" \
      '</span>'.html_safe

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
    clubs_for_domain
      .sort_by { rand }
      .take(clubs_to_display)
      .sort_by(&:name)
  end

  def friends_to_display
    12
  end

  def clubs_to_display
    4
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

  def favorites # rubocop:disable AbcSize
    return if preferences.favorites_in_profile.zero?

    (fav_animes + fav_mangas + fav_ranobe + fav_characters + fav_people)
      .shuffle
      .take(preferences.favorites_in_profile)
      .sort_by do |fav|
        [fav.class.name == Manga.name ? Anime.name : fav.class.name, fav.name]
      end
      .map(&:decorate)
  end

  def main_comments_view
    Topics::ProxyComments.new object, false
  end

  def preview_comments_view
    Topics::ProxyComments.new object, true
  end

  def unconnected_providers
    User.omniauth_providers.select { |v| v != :google_apps && v != :yandex } -
      user_tokens.map { |v| v.provider.to_sym }
  end

  def ignored_topics
    object.topic_ignores.includes(:topic).map do |topic_ignore|
      Topics::TopicViewFactory.new(false, false).build topic_ignore.topic
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

  def website_host
    return if object.website.blank?

    URI.parse(website_url).host
  rescue URI::Error
  end

  def website_url
    return if object.website.blank?

    if object.website.match?(%r{^https?://})
      object.website
    else
      "http://#{object.website}"
    end
  end
end
