class UserHistoryDecorator < BaseDecorator
  WATCHED = {
    UserHistoryAction::EPISODES => 'watched_episodes',
    UserHistoryAction::VOLUMES => 'read_volumes',
    UserHistoryAction::CHAPTERS => 'read_chapters'
  }

  EPISODES = {
    UserHistoryAction::EPISODES => 'episode',
    UserHistoryAction::VOLUMES => 'volume',
    UserHistoryAction::CHAPTERS => 'chapter'
  }

  def time_ago interval
    if interval == :today
      i18n_t 'time_ago', time_ago: h.time_ago_in_words(updated_at)
    else
      I18n.l updated_at, format: '%-d %B'
    end
  end

  def target
    if target_type == Anime.name
      anime
    elsif target_type == Manga.name || target_type == Ranobe.name
      manga
    end
  end

  def format
    case action
      when UserHistoryAction::MAL_ANIME_IMPORT,
          UserHistoryAction::MAL_MANGA_IMPORT,
          UserHistoryAction::AP_ANIME_IMPORT,
          UserHistoryAction::AP_MANGA_IMPORT,
          UserHistoryAction::ANIME_IMPORT,
          UserHistoryAction::MANGA_IMPORT
        kind = action.match?(/anime/i) ? :anime : :manga
        records = "#{value} #{i18n_i 'record', value.to_i}"

        i18n_t "actions.import.#{kind}", records: records

      when UserHistoryAction::REGISTRATION,
          UserHistoryAction::ADD,
          UserHistoryAction::DELETE,
          UserHistoryAction::ANIME_HISTORY_CLEAR,
          UserHistoryAction::MANGA_HISTORY_CLEAR
        i18n_t "actions.#{action}"

      when UserHistoryAction::STATUS
        status_name = UserRate.statuses.find { |k, v| v == value.to_i }.first
        I18n.t "user_history_decorator.actions.status.#{status_name}",
          default: UserRate.status_name(value.to_i, target.class.name)

      when UserHistoryAction::EPISODES, UserHistoryAction::VOLUMES, UserHistoryAction::CHAPTERS
        history_episodes = send action
        target_episodes = target.send action

        if target_episodes == history_episodes.last
          kind = if target.anime?
            target.kind_movie? ? :movie : :anime
          else
            target.kind_novel? ? :novel : :manga
          end

          i18n_t "actions.episodes.completed_#{kind}"

        elsif history_episodes.one? && history_episodes.first.zero?
          kind = target.anime? ? :anime : :manga
          i18n_t "actions.episodes.reset_#{kind}"

        else
          episodes_text send("watched_#{action}"), prior_value.to_i, action
        end

      when UserHistoryAction::RATE
        rate_action = if value == '0'
          :cancelled
        elsif prior_value && prior_value != '0'
          :changed
        else
          :rated
        end

        i18n_t "actions.rate.#{rate_action}", prior_score: prior_value, score: value

      when UserHistoryAction::COMPLETE_WITH_SCORE
        i18n_t 'actions.complete_with_score',
          status_name: UserRate.status_name(:completed, target.class.name),
          score: value

      else
        target.name
    end
  end

private

  def episodes_text episodes, prior_value, division
    suffix = division == 'chapters' ? '-я' : '-й'

    if episodes.last && episodes.last < prior_value
      i18n_t 'watched_one_episode',
        watched: i18n_v(WATCHED[division], episodes.last),
        number: episodes.last,
        division: i18n_i(EPISODES[division], episodes.last),
        suffix: ''

    elsif episodes.size == 1
      i18n_t 'watched_one_episode',
        watched: i18n_v(WATCHED[division], :one),
        number: episodes.first,
        division: i18n_io(EPISODES[division], :one),
        suffix: suffix

    elsif episodes.size == 2
      i18n_t 'watched_two_episodes',
        watched: i18n_v(WATCHED[division], :few),
        number_first: episodes.first,
        number_second: episodes.second,
        division: i18n_io(EPISODES[division], :few),
        suffix: suffix

    elsif episodes.size == 3
      i18n_t 'watched_three_episodes',
        watched: i18n_v(WATCHED[division], :few),
        number_first: episodes.first,
        number_second: episodes.second,
        number_third: episodes.third,
        division: i18n_io(EPISODES[division], :few),
        suffix: suffix

    elsif episodes.first == 1
      i18n_t 'watched_first_episodes',
        watched: i18n_v(WATCHED[division], episodes.last),
        number: episodes.last,
        division: i18n_i(EPISODES[division], episodes.last),
        suffix: ''

    else
      i18n_t 'watched_episodes_range',
        watched: i18n_v(WATCHED[division], :few),
        number_first: episodes.first,
        number_last: episodes.last,
        division: i18n_io(EPISODES[division], :few),
        suffix_first: (division == 'chapters' ? '-й' : '-го'),
        suffix_last: (division == 'chapters' ? '-ю' : suffix)
    end.capitalize
  end
end
