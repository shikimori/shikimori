class UserProfileHistoryDecorator < Draper::Decorator
  delegate_all
  LIMIT = 4

  # отформатированная история
  def formatted
    @formatted ||= Rails.cache.fetch [:history, object, I18n.locale] do
      grouped_history.map { |_, entries| format entries }.compact
    end
  end

  def any?
    object.history.any?
  end

private

  # история
  def history
    @history ||= all_history
      .limit(LIMIT * 4)
      .decorate
  end

  def grouped_history
    history
      .group_by { |v| "#{v.target_id || v.action[0]}_#{v.updated_at.strftime "%d-%m-%y"}" }
      .take(LIMIT)
  end

  def format entries
    entry = entries.first

    if UserHistoryAction::Registration == entry.action
      Users::FormattedHistory.new(
        image: '/assets/blocks/history/shikimori.x43.png',
        name: Site::DOMAIN,
        action: entries.reverse.map(&:format).join(', ').html_safe,
        action_info: I18n.t("enumerize.user_history_action.action.#{entry.action}"),
        created_at: entry.created_at,
        url: "http://#{Site::DOMAIN}"
      )

    elsif [UserHistoryAction::MalAnimeImport, UserHistoryAction::MalMangaImport].include? entry.action
      Users::FormattedHistory.new(
        image: '/assets/blocks/history/mal.png',
        name: 'MyAnimeList',
        action: entries.reverse.map(&:format).join(', ').html_safe,
        action_info: I18n.t("enumerize.user_history_action.action.#{entry.action}"),
        created_at: entry.created_at,
        url: 'http://myanimelist.net'
      )

    elsif [UserHistoryAction::ApAnimeImport, UserHistoryAction::ApMangaImport].include? entry.action
      Users::FormattedHistory.new(
        image: '/assets/blocks/history/anime-planet.jpg',
        name: 'Anime-Planet',
        action: entries.reverse.map(&:format).join(', ').html_safe,
        action_info: I18n.t("enumerize.user_history_action.action.#{entry.action}"),
        created_at: entry.created_at,
        url: 'http://anime-planet.com'
      )

    elsif entry.target.nil?
      nil

    else
      Users::FormattedHistory.new(
        image: ImageUrlGenerator.instance.url(entry.target, :x48),
        image_2x: ImageUrlGenerator.instance.url(entry.target, :x96),
        name: entry.target.name,
        russian: entry.target.russian,
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        url: h.url_for(entry.target)
      )
    end
  end
end
