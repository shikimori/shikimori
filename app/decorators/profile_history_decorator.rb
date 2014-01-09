class ProfileHistoryDecorator < UserDecorator
  def initialize object, history_limit = 3
    super object
    @history_limit = history_limit
  end

  # отформатированная история
  def formatted
    grouped_history
      .map {|group,entries| format_entries entries }
      .compact
      .each do |entry|
        entry[:reversed_action] = entry[:action].split(/(?<!\d[йяюо]), /).reverse.join(', ').gsub(/<.*?>/, '')
      end
  end

  def any?
    object.history.any?
  end

private
  # история
  def history
    @history ||= all_history
      .order { updated_at desc }
      .limit(@history_limit*4)
  end

  def grouped_history
    history
      .group_by {|v| "#{v.target_id || v.action[0]}_#{v.updated_at.strftime "%d-%m-%y"}" }
      .take(@history_limit)
  end

  def format_entries entries
    entry = entries.first

    if UserHistoryAction::Registration == entry.action
      {
        image: '/assets/blocks/history/shikimori.x43.png',
        name: 'shikimori.org',
        action: entries.reverse.map {|v| UserPresenter.history_entry_text(v) }.join(', ').html_safe,
        time: h.time_ago_in_words(entry.created_at, "%s назад"),
        url: 'http://shikimori.org'
      }
    elsif [UserHistoryAction::MalAnimeImport, UserHistoryAction::MalMangaImport].include? entry.action
      {
        image: '/assets/blocks/history/mal.png',
        name: 'MyAnimeList',
        action: entries.reverse.map {|v| UserPresenter.history_entry_text(v) }.join(', ').html_safe,
        time: h.time_ago_in_words(entry.created_at, "%s назад"),
        url: 'http://myanimelist.net'
      }
    elsif [UserHistoryAction::ApAnimeImport, UserHistoryAction::ApMangaImport].include? entry.action
      {
        image: '/assets/blocks/history/anime-planet.jpg',
        name: 'Anime-Planet',
        action: entries.reverse.map {|v| UserPresenter.history_entry_text(v) }.join(', ').html_safe,
        time: h.time_ago_in_words(entry.created_at, "%s назад"),
        url: 'http://anime-planet.com'
      }
    elsif entry.target.nil?
      nil
    else
      {
        image: entry.target.image.url(:x64),
        name: h.localized_name(entry.target),
        action: entries.reverse.map {|v| UserPresenter.history_entry_text(v) }.join(', ').html_safe,
        time: h.time_ago_in_words(entry.created_at, "%s назад"),
        url: h.url_for(entry.target)
      }
    end
  end
end

