# TODO: move methods into Profiles::View and other classes
class UserProfileDecorator < UserDecorator
  instance_cache :all_compatibility, :friends, :ignored?,
    :nickname_changes, :favorites,
    :main_comments_view, :preview_comments_view, :ignored_topics,
    :random_clubs

  # list of users with abusive content in profile
  # (reported by moderators or roskomnadzor)

  def website
    return '' if website_host.blank?

    h.link_to h.h(website_host), h.h(website_url), class: 'website'
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

  def friends
    object.friends.order(last_online_at: :desc)
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
