# TODO: refactor
class Users::StatisticsQuery
  prepend ActiveCacher.instance
  instance_cache :activity_stats

  attr_reader :anime_rates, :anime_valuable_rates,
    :manga_rates, :manga_valuable_rates,
    :genres, :studios, :publishers

  # стандартный формат дат для сравнения
  DATE_FORMAT = '%Y-%m-%d'
  DAY_INTERVAL = 60 * 60 * 24

  def initialize user
    @user = user
    @preferences = user.preferences

    @anime_rates = @user
      .anime_rates
      .joins('join animes on animes.id = target_id')
      .select('user_rates.*, animes.rating, animes.kind, animes.duration,
        animes.episodes as entry_episodes, animes.episodes_aired as entry_episodes_aired')
      .map { |anime| ExtendedUserRate.new anime }

    @anime_valuable_rates = @anime_rates.reject { |v| v.dropped? || v.planned? }
    @anime_history = @user
      .history
      .where.not(anime_id: nil)
      .where(
        'action in (?) or (action = ? and value in (?))',
        [
          UserHistoryAction::EPISODES,
          UserHistoryAction::COMPLETE_WITH_SCORE,
          UserHistoryAction::ADD
        ],
        UserHistoryAction::STATUS,
        [
          UserRate.statuses[:completed].to_s,
          UserRate.statuses[:rewatching].to_s
        ]
      )
    # @imports = @user.history.where(action: [UserHistoryAction::MAL_ANIME_IMPORT, UserHistoryAction::AP_ANIME_IMPORT, UserHistoryAction::MAL_MANGA_IMPORT, UserHistoryAction::AP_MANGA_IMPORT])

    @manga_rates = @user
      .manga_rates
      .joins('join mangas on mangas.id = target_id')
      .select("user_rates.*, mangas.type, mangas.rating, mangas.kind,
      #{Manga::CHAPTER_DURATION} as duration,
        mangas.chapters as entry_episodes, 0 as entry_episodes_aired,
        mangas.chapters as entry_chapters, mangas.volumes as entry_volumes")
      .map { |manga| ExtendedUserRate.new manga }

    @manga_valuable_rates = @manga_rates.reject { |v| v.dropped? || v.planned? }
    @manga_history = @user
      .history
      .where.not(manga_id: nil)
      .where('action in (?) or (action = ? and value in (?))',
        [
          UserHistoryAction::CHAPTERS,
          UserHistoryAction::COMPLETE_WITH_SCORE,
          UserHistoryAction::ADD
        ],
        UserHistoryAction::STATUS,
        [
          UserRate.statuses[:completed].to_s,
          UserRate.statuses[:rewatching].to_s
        ])
  end

  # статистика активности просмотра аниме / чтения манги
  def by_activity(intervals)
    @by_activity ||= {}
    @by_activity[intervals] ||= compute_by_activity(*activity_stats, intervals)
  end

  def activity_stats
    histories = @anime_history + @manga_history
    rates = @anime_rates + @manga_rates

    # удаляем всё без duration т.к. по ним активность всё равно 0 посчитается
    rates.select!(&:duration)

    rates_cache = rates.index_by do |rate|
      "#{rate.target_id}#{rate.target_type}"
    end
    cache_keys = Set.new rates_cache.keys

    # минимальная дата старта статистики
    if @preferences.statistics_start_on
      histories.select! { |v| v.created_at >= @preferences.statistics_start_on }
    end

    # добавленные аниме
    added = histories
      .select { |v| v.action == UserHistoryAction::ADD }
      .uniq { |v| [v.target_id, v.target_type] }

    # удаляем все добавленыне
    histories.delete_if { |v| v.action == UserHistoryAction::ADD }

    # кеш для быстрой проверки наличия в истории
    present_histories = histories.each_with_object({}) do |v, rez|
      rez["#{v.target_id}#{v.target_type}"] = true
    end
    # возвращаем добавленные назад, если у добавленных нет
    # ни одной записи в истории, но в тоже время у добавленных есть
    # потраченное на просмотр время
    added = added
      .reject { |v| present_histories["#{v.target_id}#{v.target_type}"] }
      .each do |history|
        rate = rates_cache["#{history.target_id}#{history.target_type}"]

        # аниме может быть запланированным с указанным числом эпизодов.
        # такое не надо учитывать
        if rate && !rate.planned?
          history.value = rate.episodes.positive? ? rate.episodes : rate.chapters
        end
      end
      .select { |history| history.value.to_i.positive? }

    histories += added

    imported = Set.new(histories)
      .select do |v|
        v.action == UserHistoryAction::STATUS ||
          v.action == UserHistoryAction::COMPLETE_WITH_SCORE
      end
      .group_by { |v| v.updated_at.strftime DATE_FORMAT }
      .select { |_k, v| v.size > 15 }
      .values
      .flatten
      .map(&:id)

    # переписываем rates_cache на нужный нам формат данных
    rates_cache = rates.each_with_object(rates_cache) do |v, rez|
      # запланированные не учитываем
      rez["#{v.target_id}#{v.target_type}"] = {
        duration: v[:duration],
        completed: 0,
        episodes: (
          v[:entry_episodes].positive? ? v[:entry_episodes] : v[:entry_episodes_aired]
        )
      }
    end

    # исключаем импортированное
    histories = histories.reject { |v| imported.include?(v.id) }
    # исключаем то, для чего rates нет, т.е. впоследствии удалённое из списка
    histories = histories.select { |v| cache_keys.include?("#{v.target_id}#{v.target_type}") }

    [
      histories,
      rates_cache
    ]
  end

  # вычисление статистики активности просмотра аниме / чтения манги
  def compute_by_activity histories, rates_cache, intervals
    return {} if histories.none?

    # cleanup rates_cache because compute_by_activity is called twice
    rates_cache.each { |_k, v| v[:completed] = 0 }

    start_date = histories.map(&:created_at).min.to_datetime.beginning_of_day
    end_date = histories.map(&:updated_at).max.to_datetime.end_of_day

    # не меньше суток
    distance = [(end_date.to_i - start_date.to_i) / intervals, DAY_INTERVAL].max
    # if distance < DAY_INTERVAL * 7
      # distance = distance - distance % DAY_INTERVAL
    # end

    0.upto(intervals - 1).map do |num|
      from = start_date + (distance * num).seconds
      to = from + distance.seconds - (num == intervals ? 0 : 1.second)

      next if from > Time.zone.now || from > end_date + 1.hour

      history = histories
        .select { |v| v.updated_at >= from && v.updated_at < to }

      spent_time = 0

      # сортировка это важно, история должна обрабатывать в том порядке,
      # в каком её создали и затем меняли.
      # могли добавить в список (1). поставить большую часть эпизодов (2).
      # поменять статус (1) на completed. и получится, что запись о completed (1)
      # расположена в базе раньше, чем запись об эпизодах (2).
      # но updated_at у (1) при этом больше, чем updated_at у (2)
      history.sort_by(&:updated_at).each do |entry|
        cached = rates_cache["#{entry.target_id}#{entry.target_type}"]

        # запись о начале пересмотра - сбрасывем счётчик
        if entry.action == UserHistoryAction::STATUS &&
            entry.value.to_i == UserRate.status_id(:rewatching)
          cached[:completed]
          next
        end

        entry_time = cached[:duration] / 60.0 *
          if entry.action == UserHistoryAction::COMPLETE_WITH_SCORE ||
              entry.action == UserHistoryAction::STATUS
            completed = cached[:completed]

            # запись о завершении просмотра - ставим счётчик просмотренного на общее число эпизодов
            if entry.action == UserHistoryAction::STATUS &&
                entry.value.to_i == UserRate.status_id(:completed)
              cached[:completed] = cached[:episodes]
            end

            # бывает ситуация, когда точное число эпизодов не известно и completed > episodes, в таком случае берём абсолютное значение
            (cached[:episodes] - completed).abs
          else
            episodes = entry.value.split(',').map(&:to_i)
            episodes.unshift(entry.prior_value.to_i + 1)
            episodes.uniq!

            completed = cached[:completed]

            # ap episodes
            # откусываем с конца элементы, т.к. могут задать меньшее число эпизодов после большего
            episodes.pop while episodes.length > 1 && episodes.last < episodes.first
            # ap episodes

            if episodes.size == 1
              cached[:completed] = episodes.first

              if completed > episodes.first
                0
              else
                episodes.first - completed
              end
            else
              cached[:completed] = episodes.last
              count = episodes.last - episodes.first + 1

              # могли указать какой-нибудь сериал, что смотрят сейчас какую-нибудь сотую серию и посчитается как 100-1
              if count > 60
                5
              else
                count
              end
            end
          end

        # ap [entry, entry_time]
        spent_time += entry_time
      end

      Profiles::ActivityStat.new(
        name: [from.to_i, to.to_i],
        value: spent_time.ceil
      )
    end.compact
  end

  # статистика по определённому критерию
  def by_criteria criteria, variants, i18n = nil, filter = ->(_v) { true }
    [
      { klass: Anime, rates: @anime_valuable_rates },
      { klass: Manga, rates: @manga_valuable_rates }
    ].each_with_object({}) do |stat, rez|
      entry = variants.map do |variant|
        value = stat[:rates]
          .select { |v| filter.call(v) }
          .count { |v| v[criteria] == variant }
        next if value.zero?

        Profiles::CriteriaStat.new(
          name: i18n ? I18n.t(i18n.sub(':klass', stat[:klass].name) % variant) : variant,
          value: value
        )
      end.compact

      rez[stat[:klass].name.downcase.to_sym] = entry
    end
  end

  def anime_statuses is_full
    statuses @anime_rates, is_full, Anime.name
  end

  def manga_statuses is_full
    statuses @manga_rates, is_full, Manga.name
  end

  def statuses rates, is_full, type
    UserRate.statuses.map do |status_name, status_id|
      next if !is_full && status_name == 'rewatching'

      Profiles::ListStats.new(
        id: status_id,
        grouped_id: !is_full && status_name == 'watching' ?
          "#{status_name},rewatching" :
          status_name,
        name: status_name,
        size: !is_full && status_name == 'watching' ?
          rates.count { |v| v.watching? || v.rewatching? } :
          rates.count { |v| v.status == status_name },
        type: type
      )
    end.compact
  end

  # статистика по статусам аниме и манги в списке пользователя
  def stats_bars
    lists = [
      ([Anime.name, anime_statuses(false)] if @preferences.anime_in_profile?),
      ([Manga.name, manga_statuses(false)] if @preferences.manga_in_profile?)
    ]

    lists
      .compact
      .map do |type, lists_stats|
        Profiles::BarStats.new type: type, lists_stats: lists_stats
      end
      .select(&:any?)
  end

  # выборка статистики по категориям в списке пользователя
  def by_categories(category_name, categories, anime_rates, manga_rates, limit)
    # статистика по предпочитаемым элементам
    categories_by_id = categories.index_by do |v|
      v.id
    end

    # выборка подсчитываемых элементов
    rates = []
    [
      ['anime', anime_rates || []],
      ['manga', manga_rates || []]
    ].each do |type, rates_data|
      # указывает ли пользовать вообще оценки?
      no_scores = (rates_data || []).all? { |v| v.score.nil? || v.score.zero? }

      ids = (
        no_scores ?
          rates_data :
          rates_data.select { |v| v.score && v.score >= 7 }
      ).map(&:target_id)

      rates +=
        if ids.any?
          type.classify.constantize
            .where(id: ids)
            .select("#{category_name}_ids")
            .flat_map(&:"#{category_name}_ids")
            .map { |id| categories_by_id[id] }
            .select(&:present?)
            # .select { |v| v && v.name != 'School' && v.name != 'Action' }
        else
          []
        end
    end

    stats_by_categories = rates.each_with_object({}) do |v, memo|
      memo[v] ||= 0
      memo[v] += 1
    end.sort_by { |_k, v| v }.reverse.take(limit)

    # подсчёт процентов
    sum = stats_by_categories.sum { |_k, v| v }.to_f

    stats =
      if sum > 8
        stats_by_categories.map do |k, v|
          [k, ((v * 1000 / sum).to_i / 10.0).to_f]
        end
      else
        []
      end.compact.sort_by { |k, _v| k.name }

    if stats.any?
      # для жанров занижаем долю комедий
      if category_name == 'genre'
        stats.map! do |genre|
          if genre[0].name == 'Comedy'
            [genre[0], genre[1] * 0.6]
          else
            genre
          end
        end
      end
      max = stats.max_by { |a| a[1] }[1]
      min = stats.min_by { |a| a[1] }[1]

      stats.map do |category|
        {
          category: category[0],
          percent: category[1],
          scale: max == min ? 1 : ((category[1] - min) / (max - min) * 4).round(0).to_i
        }
      end
    else
      stats
    end
  end
end
