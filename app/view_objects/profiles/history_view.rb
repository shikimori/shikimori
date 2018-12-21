class Profiles::HistoryView < ViewObjectBase
  vattr_initialize :user

  SHIKIMORI_ACTIONS = [
    UserHistoryAction::REGISTRATION,
    UserHistoryAction::ANIME_IMPORT,
    UserHistoryAction::MANGA_IMPORT
  ]
  MAL_IMPORT_ACTIONS = [
    UserHistoryAction::MAL_ANIME_IMPORT,
    UserHistoryAction::MAL_MANGA_IMPORT
  ]
  AP_IMPORT_ACTIONS = [
    UserHistoryAction::AP_ANIME_IMPORT,
    UserHistoryAction::AP_MANGA_IMPORT
  ]

  LIMIT = 4

  def display?
    formatted.any?
  end

  def preview
    formatted.take(anime_with_manga? ? 3 : 2)
  end

private

  def formatted
    @formatted ||= Rails.cache.fetch [:history, @user, I18n.locale] do
      grouped_history.map { |_, entries| format entries }.compact
    end
  end

  def anime_with_manga?
    @user.stats.anime? && @user.stats.manga? &&
      @user.preferences.anime_in_profile? && @user.preferences.manga_in_profile?
  end

  def history
    @history ||= @user.all_history
      .limit(LIMIT * 4)
      .decorate
  end

  def grouped_history
    history
      .group_by { |v| "#{v.target_id || v.action[0]}_#{v.updated_at.strftime '%d-%m-%y'}" }
      .take(LIMIT)
  end

  def format entries
    action = entries.first.action

    if SHIKIMORI_ACTIONS.include? action
      format_shikimori_action entries

    elsif MAL_IMPORT_ACTIONS.include? action
      format_mal_import entries

    elsif AP_IMPORT_ACTIONS.include? action
      format_ap_import entries

    elsif entry.target.nil?
      nil

    else
      format_default entries
    end
  end

  def format_shikimori_action entries
    Users::FormattedHistory.new(
      image: '/assets/blocks/history/shikimori.x43.png',
      name: Shikimori::DOMAIN,
      action: entries.reverse.map(&:format).join(', ').html_safe,
      action_info: I18n.t("enumerize.user_history_action.action.#{entries.first.action}"),
      created_at: entries.first.created_at,
      url: "http://#{Shikimori::DOMAIN}"
    )
  end

  def format_mal_import entries
    Users::FormattedHistory.new(
      image: '/assets/blocks/history/mal.png',
      name: 'MyAnimeList',
      action: entries.reverse.map(&:format).join(', ').html_safe,
      action_info: I18n.t("enumerize.user_history_action.action.#{entries.first.action}"),
      created_at: entries.first.created_at,
      url: 'http://myanimelist.net'
    )
  end

  def format_ap_import entries
    Users::FormattedHistory.new(
      image: '/assets/blocks/history/anime-planet.jpg',
      name: 'Anime-Planet',
      action: entries.reverse.map(&:format).join(', ').html_safe,
      action_info: I18n.t("enumerize.user_history_action.action.#{entries.first.action}"),
      created_at: entries.first.created_at,
      url: 'http://anime-planet.com'
    )
  end

  def format_default entries
    entry = entries.first
    target = entry.target

    Users::FormattedHistory.new(
      image: ImageUrlGenerator.instance.url(target, :x48),
      image_2x: ImageUrlGenerator.instance.url(target, :x96),
      name: target.name,
      russian: target.russian,
      action: entries.reverse.map(&:format).join(', ').html_safe,
      created_at: entry.created_at,
      url: h.url_for(target)
    )
  end
end
