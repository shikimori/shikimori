class UserProfileHistoryDecorator < Draper::Decorator
  delegate_all
  LIMIT = 4

  # отформатированная история
  def formatted
    @formatted ||= Rails.cache.fetch [:history, h.russian_names_key, object.cache_key] do
      grouped_history
        .map { |_, entries| format_entries entries }
        .compact
        .each do |entry|
          entry[:reversed_action] = entry[:action]
            .split(/(?<!\d[йяюо]), (?!\d)/)
            .reverse
            .join(', ')
            .gsub(/<.*?>/, '')
        end
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

  def format_entries entries
    entry = entries.first

    if UserHistoryAction::Registration == entry.action
      {
        image: '/assets/blocks/history/shikimori.x43.png',
        name: Site::DOMAIN,
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        url: "http://#{Site::DOMAIN}",
        short_name: I18n.t("enumerize.user_history_action.action.#{entry.action}"),
        special?: true
      }

    elsif [UserHistoryAction::MalAnimeImport, UserHistoryAction::MalMangaImport].include? entry.action
      {
        image: '/assets/blocks/history/mal.png',
        name: 'MyAnimeList',
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        url: 'http://myanimelist.net',
        short_name: I18n.t("enumerize.user_history_action.action.#{entry.action}"),
        special?: true
      }

    elsif [UserHistoryAction::ApAnimeImport, UserHistoryAction::ApMangaImport].include? entry.action
      {
        image: '/assets/blocks/history/anime-planet.jpg',
        name: 'Anime-Planet',
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        url: 'http://anime-planet.com',
        short_name: I18n.t("enumerize.user_history_action.action.#{entry.action}"),
        special?: true
      }

    elsif entry.target.nil?
      nil

    else
      {
        image: ImageUrlGenerator.instance.url(entry.target, :x48),
        image_2x: ImageUrlGenerator.instance.url(entry.target, :x96),
        name: UsersHelper.localized_name(entry.target, h.current_user),
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        url: h.url_for(entry.target),
        special?: false
      }
    end
  end
end
