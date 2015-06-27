class UserHistoryDecorator < Draper::Decorator
  include Translation

  delegate_all

  def time_ago interval
    if interval == :today
      i18n_t 'time_ago', time_ago: h.time_ago_in_words(updated_at)
    else
      I18n.l updated_at, format: '%-d %B'
    end
  end

  def format
    case action
      when UserHistoryAction::MalAnimeImport,
          UserHistoryAction::MalMangaImport,
          UserHistoryAction::ApAnimeImport,
          UserHistoryAction::ApMangaImport
        kind = action =~ /anime/i ? :anime : :manga
        records = "#{value} #{i18n_i 'record', value.to_i}"

        i18n_t "actions.import.#{kind}", records: records

      when UserHistoryAction::Registration,
          UserHistoryAction::Add,
          UserHistoryAction::Delete,
          UserHistoryAction::AnimeHistoryClear,
          UserHistoryAction::MangaHistoryClear
        i18n_t "actions.#{action}"

      when UserHistoryAction::Status
        UserRate.status_name value.to_i, target.class.name

      when UserHistoryAction::Episodes, UserHistoryAction::Volumes, UserHistoryAction::Chapters
        history_episodes = send action
        target_episodes = target.send action

        if target_episodes == history_episodes.last
          kind = if target.anime?
            target.movie? ? :movie : :anime
          else
            target.novel? ? :novel : :manga
          end

          i18n_t "actions.episodes.completed_#{kind}"

        elsif history_episodes.one? && history_episodes.first.zero?
          kind = target.anime? ? :anime : :manga
          i18n_t "actions.episodes.reset_#{kind}"

        else
          episodes_text send("watched_#{action}"), prior_value.to_i, action
        end

      when UserHistoryAction::Rate
        rate_action = if value == '0'
          :cancelled
        elsif prior_value && prior_value != '0'
          :changed
        else
          :rated
        end

        i18n_t "actions.rate.#{rate_action}", prior_score: prior_value, score: value

      when UserHistoryAction::CompleteWithScore
        i18n_t 'actions.complete_with_score',
          status_name: UserRate.status_name(:completed, target.class.name),
          score: value

      else
        target.name
    end
  end

private

  def episodes_text episodes, prior_value, counter
    suffix = counter == 'chapters' ? 'я' : 'й'

    if episodes.last && episodes.last < prior_value
      "%s #{episodes.last} %s" % [
        Russian.p(episodes.last, wt('Просмотрен', counter), wt('Просмотрены', counter), wt('Просмотрено', counter)),
        Russian.p(episodes.last, wt('эпизод', counter), wt('эпизода', counter), wt('эпизодов', counter))
      ]

    elsif episodes.size == 1
      "#{wt 'Просмотрен', counter} #{episodes.first}#{suffix} #{wt 'эпизод', counter}"

    elsif episodes.size == 2
      "#{wt 'Просмотрены', counter} #{episodes.first}#{suffix} и #{episodes.last}#{suffix} #{wt 'эпизоды', counter}"

    elsif episodes.size == 3
      "#{wt 'Просмотрены', counter} #{episodes.first}#{suffix}, #{episodes.second}#{suffix} и #{episodes.last}#{suffix} #{wt('эпизоды', counter)}"

    elsif episodes.first == 1
      "%s #{episodes.last} %s" % [
        Russian.p(episodes.last, wt('Просмотрен', counter), wt('Просмотрены', counter), wt('Просмотрено', counter)),
        Russian.p(episodes.last, wt('эпизод', counter), wt('эпизода', counter), wt('эпизодов', counter))
      ]

    else
      "#{wt 'Просмотрены', counter} с #{episodes.first}%s по #{episodes.last}%s #{wt "эпизоды", counter}" % [
        counter == 'chapters' ? 'й' : 'го',
        counter == 'chapters' ? 'ю' : suffix
      ]
    end
  end

  def wt label, counter
    @wt ||= {
      'Просмотрен' => {
        'episodes' => 'Просмотрен',
        'volumes' => 'Прочитан',
        'chapters' => 'Прочитана'
      },
      'Просмотрены' => {
        'episodes' => 'Просмотрены',
        'volumes' => 'Прочитаны',
        'chapters' => 'Прочитаны'
      },
      'Просмотрено' => {
        'episodes' => 'Просмотрено',
        'volumes' => 'Прочитано',
        'chapters' => 'Прочитано'
      },
      'эпизод' => {
        'episodes' => 'эпизод',
        'volumes' => 'том',
        'chapters' => 'глава'
      },
      'эпизода' => {
        'episodes' => 'эпизода',
        'volumes' => 'тома',
        'chapters' => 'главы'
      },
      'эпизодов' => {
        'episodes' => 'эпизодов',
        'volumes' => 'томов',
        'chapters' => 'глав'
      },
      'эпизоды' => {
        'episodes' => 'эпизоды',
        'volumes' => 'тома',
        'chapters' => 'главы'
      }
    }
    @wt[label][counter]
  end
end
