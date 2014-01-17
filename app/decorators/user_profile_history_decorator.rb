# TODO: выпилить ключ :time в хеше, он не актуален, т.к. всё кешируется
class UserProfileHistoryDecorator < Draper::Decorator
  delegate_all

  LIMIT = 4

  # отформатированная история
  def formatted
    @formatted ||= Rails.cache.fetch [:history, :v2, :formatted, object, h.russian_names_key] do
      grouped_history
        .map {|group,entries| format_entries entries }
        .compact
        .each do |entry|
          entry[:reversed_action] = entry[:action].split(/(?<!\d[йяюо]), /).reverse.join(', ').gsub(/<.*?>/, '')
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
      .order { updated_at.desc }
      .limit(LIMIT * 4)
      .decorate
  end

  def grouped_history
    history
      .group_by {|v| "#{v.target_id || v.action[0]}_#{v.updated_at.strftime "%d-%m-%y"}" }
      .take(LIMIT)
  end

  def format_entries entries
    entry = entries.first

    if UserHistoryAction::Registration == entry.action
      {
        image: '/assets/blocks/history/shikimori.x43.png',
        name: 'shikimori.org',
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        time: h.time_ago_in_words(entry.created_at, "%s назад"),
        url: 'http://shikimori.org',
        short_name: 'Регистрация на сайте',
        special?: true
      }
    elsif [UserHistoryAction::MalAnimeImport, UserHistoryAction::MalMangaImport].include? entry.action
      {
        image: '/assets/blocks/history/mal.png',
        name: 'MyAnimeList',
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        time: h.time_ago_in_words(entry.created_at, "%s назад"),
        url: 'http://myanimelist.net',
        short_name: 'Импорт с MyAnimeList',
        special?: true
      }
    elsif [UserHistoryAction::ApAnimeImport, UserHistoryAction::ApMangaImport].include? entry.action
      {
        image: '/assets/blocks/history/anime-planet.jpg',
        name: 'Anime-Planet',
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        time: h.time_ago_in_words(entry.created_at, "%s назад"),
        url: 'http://anime-planet.com',
        short_name: 'Импорт с Anime-Planet',
        special?: true
      }
    elsif entry.target.nil?
      nil
    else
      {
        image: entry.target.image.url(:x64),
        name: UsersHelper.localized_name(entry.target, h.current_user),
        action: entries.reverse.map(&:format).join(', ').html_safe,
        created_at: entry.created_at,
        time: h.time_ago_in_words(entry.created_at, "%s назад"),
        url: h.url_for(entry.target),
        special?: false
      }
    end
  end
end

