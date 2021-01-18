# TODO: move methods into Profiles::View and other Profiles::*View classes
class UserProfileDecorator < UserDecorator
  instance_cache :nickname_changes?,
    :all_compatibility, :friends, :favorites,
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
    Users::NicknameChangesQuery.call(object, h.can?(:manage, Ban)).any?
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

  def favorites
    return if preferences.favorites_in_profile.zero?

    object
      .favourites
      .includes(:linked)
      .order(Arel.sql('random()'))
      .limit(preferences.favorites_in_profile)
      .sort_by do |favorite|
        [
          favorite.linked_type == Manga.name ? 'Anime1' : favorite.linked_type,
          favorite.position
        ]
      end
      .map(&:linked)
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
