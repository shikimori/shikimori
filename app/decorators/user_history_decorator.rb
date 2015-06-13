class UserHistoryDecorator < Draper::Decorator
  include Translation

  delegate_all

  def time_ago interval
    if interval == :today
      i18n_t 'time_ago', time_ago: h.time_ago_in_words(update_at)
    else
      I18n.l updated_at, format: '%-d %B'
    end
  end

  def format
    case action
      when UserHistoryAction::MalAnimeImport, UserHistoryAction::MalMangaImport, UserHistoryAction::ApAnimeImport, UserHistoryAction::ApMangaImport
        "Импортирован#{[UserHistoryAction::MalAnimeImport, UserHistoryAction::ApAnimeImport].include?(action) ? 'о аниме' : 'а манга'} - #{value} #{Russian.p(value.to_i, 'запись', 'записи', 'записей')}"

      when UserHistoryAction::Registration
        'Регистрация на сайте'

      when UserHistoryAction::Add
        'Добавлено в список'

      when UserHistoryAction::Delete
        'Удалено из списка'

      when UserHistoryAction::AnimeHistoryClear
        'Очистка истории аниме'

      when UserHistoryAction::MangaHistoryClear
        'Очистка истории манги'

      when UserHistoryAction::Status
        UserRate.status_name value.to_i, target.class.name

      when UserHistoryAction::Episodes, UserHistoryAction::Volumes, UserHistoryAction::Chapters
        counter = case action
          when UserHistoryAction::Episodes
            'episodes'
          when UserHistoryAction::Volumes
            'volumes'
          when UserHistoryAction::Chapters
            'chapters'
        end

        if target.send(counter) == send(counter).last
          if target.kind == 'Movie' && target.send(counter) == 1
            'Просмотрен фильм'
          else
            case action
              when UserHistoryAction::Episodes
                'Просмотрены все эпизоды'
              when UserHistoryAction::Volumes, UserHistoryAction::Chapters
                "Прочитана #{target == 'Novel' ? 'новелла' : 'манга'}"
            end
          end
        else
          if send(counter).size == 1 && send(counter).first == 0
            case action
              when UserHistoryAction::Episodes
                'Сброшено число эпизодов'
              when UserHistoryAction::Volumes, UserHistoryAction::Chapters
                'Сброшено число томов и глав'
            end
          else
            episodes_text send("watched_#{counter}"), prior_value.to_i, counter
          end
        end

      when UserHistoryAction::Rate
        if value == '0'
          'Отменена оценка'
        elsif prior_value && prior_value != '0'
          "Изменена оценка c <b>#{prior_value}</b> на <b>#{value}</b>"
        else
          "Оценено на <b>#{value}</b>"
        end

      when UserHistoryAction::CompleteWithScore
        "#{UserRate.status_name :completed, target.class.name} и оценено на <b>#{value}</b>"

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
