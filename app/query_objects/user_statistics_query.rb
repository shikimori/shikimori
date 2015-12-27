class UserStatisticsQuery
  prepend ActiveCacher.instance
  instance_cache :activity_stats

  attr_reader :anime_rates, :anime_valuable_rates
  attr_reader :manga_rates, :manga_valuable_rates
  #attr_reader :genres, :studios, :publishers

  # стандартный формат дат для сравнения
  DATE_FORMAT = "%Y-%m-%d"
  DAY_INTERVAL = 60*60*24

  def initialize user
    @user = user
    @preferences = user.preferences

    @anime_rates = @user
      .anime_rates
      .joins('join animes on animes.id = target_id')
      .select('user_rates.*, animes.rating, animes.kind, animes.duration,
        animes.episodes as entry_episodes, animes.episodes_aired as entry_episodes_aired')
      .map { |anime| ExtendedUserRate.new anime }

    @anime_valuable_rates = @anime_rates.select {|v| v.completed? || v.watching? || v.rewatching? }
    @anime_history = @user
      .history
      .where(target_type: Anime.name)
      .where("action in (?) or (action = ? and value in (?))",
              [UserHistoryAction::Episodes, UserHistoryAction::CompleteWithScore, UserHistoryAction::Add],
              UserHistoryAction::Status,
              [UserRate.statuses[:completed].to_s, UserRate.statuses[:rewatching].to_s])
    #@imports = @user.history.where(action: [UserHistoryAction::MalAnimeImport, UserHistoryAction::ApAnimeImport, UserHistoryAction::MalMangaImport, UserHistoryAction::ApMangaImport])

    @manga_rates = @user
      .manga_rates
      .joins('join mangas on mangas.id = target_id')
      .select("user_rates.*, mangas.rating, mangas.kind, #{Manga::CHAPTER_DURATION} as duration,
        mangas.chapters as entry_episodes, 0 as entry_episodes_aired,
        mangas.chapters as entry_chapters, mangas.volumes as entry_volumes")
      .map { |manga| ExtendedUserRate.new manga }

    @manga_valuable_rates = @manga_rates.select {|v| v.completed? || v.watching? || v.rewatching? }
    @manga_history = @user
      .history
      .where(target_type: Manga.name)
      .where("action in (?) or (action = ? and value in (?))",
              [UserHistoryAction::Chapters, UserHistoryAction::CompleteWithScore, UserHistoryAction::Add],
              UserHistoryAction::Status,
              [UserRate.statuses[:completed].to_s, UserRate.statuses[:rewatching].to_s])
  end

  # статистика активности просмотра аниме / чтения манги
  def by_activity(intervals)
    @by_activity ||= {}
    @by_activity[intervals] ||= compute_by_activity *activity_stats, intervals
  end

  def activity_stats
    histories = @anime_history + @manga_history
    rates = @anime_rates + @manga_rates

    rates_cache = rates.each_with_object({}) do |rate, rez|
      rez["#{rate.target_id}#{rate.target_type}"] = rate
    end
    cache_keys = Set.new rates_cache.keys

    # минимальная дата старта статистики
    histories.select! { |v| v.created_at >= @preferences.statistics_start_on } if @preferences.statistics_start_on

    # добавленные аниме
    added = histories.select { |v| v.action == UserHistoryAction::Add }.uniq { |v| [v.target_id, v.target_type] }
    # удаляем все добавленыне
    histories.delete_if { |v| v.action == UserHistoryAction::Add }
    # кеш для быстрой проверки наличия в истории
    present_histories = histories.each_with_object({}) do |v, rez|
      rez["#{v.target_id}#{v.target_type}"] = true
    end
    # возвращаем добавленные назад, если у добавленных нет ни ожной записи в истории,
    # но в тоже время у добавленных есть потраченное на просмотр время
    added = added.select { |v| !present_histories["#{v.target_id}#{v.target_type}"] }
    added.each do |history|
      rate = rates_cache["#{history.target_id}#{history.target_type}"]
      history.value = rate.episodes > 0 ? rate.episodes : rate.chapters if rate
    end
    histories = histories + added

    imported = Set.new histories
      .select { |v| v.action == UserHistoryAction::Status || v.action == UserHistoryAction::CompleteWithScore}
      .group_by { |v| v.updated_at.strftime DATE_FORMAT }
      .select { |k, v| v.size > 15 }
      .values.flatten
      .map(&:id)

    # переписываем rates_cache на нужный нам формат данных
    rates_cache = rates.each_with_object(rates_cache) do |v, rez|
      rez["#{v.target_id}#{v.target_type}"] = {
        duration: v[:duration],
        completed: 0,
        episodes: v[:entry_episodes] > 0 ? v[:entry_episodes] : v[:entry_episodes_aired]
      }
    end

    # исключаем импортированное
    histories = histories.select { |v| !imported.include?(v.id) }
    # исключаем то, для чего rates нет, т.е. впоследствии удалённое из списка
    histories = histories.select { |v| cache_keys.include?("#{v.target_id}#{v.target_type}") }

    [
      rates,
      histories,
      rates_cache
    ]
  end

  # вычисление статистики активности просмотра аниме / чтения манги
  def compute_by_activity rates, histories, rates_cache, intervals
    return {} if histories.none?

    # cleanup rates_cache because compute_by_activity is called twice
    rates_cache.each { |k, v| v[:completed] = 0 }

    start_date = histories.map { |v| v.created_at }.min.to_datetime.beginning_of_day
    end_date = histories.map { |v| v.updated_at }.max.to_datetime.end_of_day

    # не меньше суток
    distance = [(end_date.to_i - start_date.to_i) / intervals, DAY_INTERVAL].max
    # if distance < DAY_INTERVAL * 7
      # distance = distance - distance % DAY_INTERVAL
    # end

    0.upto(intervals - 1).map do |num|
      from = start_date + (distance*num).seconds
      to = from + distance.seconds - (num == intervals ? 0 : 1.second)

      next if from > Time.zone.now || from > end_date + 1.hour

      history = histories.select { |v| v.updated_at >= from && v.updated_at < to }

      spent_time = 0

      #z=history
      #1/0 if num == 42
      #1/0 if z.any? && z.first.id != 3585457 && z.first.id != 3585459

      history.each do |entry|
        cached = rates_cache["#{entry.target_id}#{entry.target_type}"]

        # запись о начале пересмотра - сбрасывем счётчик
        if entry.action == UserHistoryAction::Status && entry.value.to_i == UserRate.status_id(:rewatching)
          cached[:completed]
          next
        end

        entry_time = cached[:duration]/60.0 * if entry.action == UserHistoryAction::CompleteWithScore || entry.action == UserHistoryAction::Status
          completed = cached[:completed]

          # запись о завершении просмотра - ставим счётчик просмотренного на общее число эпизодов
          if entry.action == UserHistoryAction::Status && entry.value.to_i == UserRate.status_id(:completed)
            cached[:completed] = cached[:episodes]
          end

          # бывает ситуация, когда точное число эпизодов не известно и completed > episodes, в таком случае берём абсолютное значение
          (cached[:episodes] - completed).abs
        else
          episodes = entry.value.split(',').map(&:to_i)
          episodes.unshift(entry.prior_value.to_i+1)
          episodes.uniq!

          completed = cached[:completed]

          # откусываем с конца элементы, т.к. могут задать меньшее число эпизодов после большего
          while episodes.length > 1 && episodes.last < episodes.first
            episodes.pop
          end

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

        raise "negative value for entry: #{entry.action}-#{entry.id}, completed: #{completed}, episodes: #{entry.value}" if entry_time < 0
        spent_time += entry_time
      end

      {
        name: [from.to_i, to.to_i],
        value: spent_time.ceil
      }
    end.compact
  end

  # статистика по определённому критерию
  def by_criteria criteria, variants, i18n = nil, filter = -> v { true }
    [{klass: Anime, rates: @anime_valuable_rates}, {klass: Manga, rates: @manga_valuable_rates}].each_with_object({}) do |stat, rez|
      entry = variants.map do |variant|
        value = stat[:rates].select { |v| filter.(v) }.select {|v| v[criteria] == variant }.size
        next if value == 0

        {
          name: i18n ? I18n.t(i18n.sub(':klass', stat[:klass].name) % variant) : variant,
          value: value
        }
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
      rewatching_id = UserRate.statuses.find {|k,v| k == 'rewatching'}.second

      Profiles::ListStats.new(
        grouped_id: !is_full && status_name == 'watching' ?
          "#{status_id},#{rewatching_id}" :
          status_id,
        name: status_name,
        size: !is_full && status_name == 'watching' ?
          rates.select { |v| v.watching? || v.rewatching? }.size :
          rates.select { |v| v.status == status_name }.size,
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
        Profiles::StatsBar.new type: type, lists_stats: lists_stats
      end
      .select(&:any?)
  end

  # выборка статистики по категориям в списке пользователя
  def by_categories(category_name, categories, anime_rates, manga_rates, limit)
    # статистика по предпочитаемым элементам
    categories_by_id = categories.inject({}) do |data,v|
      data[v.id] = v
      data
    end

    # выборка подсчитываемых элементов
    rates = []
    [['anime', anime_rates || []], ['manga', manga_rates || []]].each do |type, rates_data|
      # указывает ли пользовать вообще оценки?
      no_scores = (rates_data || []).all? { |v| v.score.nil? || v.score == 0 }

      ids = (no_scores ? rates_data : rates_data.select { |v| v.score && v.score >= 7 }).map(&:target_id)

      rates += if ids.any?
        query = "select #{category_name}_id from #{[category_name.tableize, type.pluralize].sort.join('_')} where #{type}_id in (#{ids.join(',')})"
        ActiveRecord::Base
          .connection
          .execute(query)
          .to_enum
          .map { |v| categories_by_id.include?(v["#{category_name}_id"].to_i) ? categories_by_id[v["#{category_name}_id"].to_i] : nil }
          .select { |v| v && v != 'School' && v != 'Action' }
      else
          []
      end
    end

    stats_by_categories = rates.each_with_object({}) do |v,memo|
      memo[v] ||= 0
      memo[v] += 1
    end.sort_by {|k,v| v }.reverse.take(limit)

    # подсчёт процентов
    sum = stats_by_categories.sum {|k,v| v }.to_f

    stats = if sum > 8
      stats_by_categories.map do |k,v|
        [k, ((v * 1000 / sum).to_i / 10.0).to_f]
      end
    else
      []
    end.compact.sort_by {|k,v| k.name }

    if stats.any?
      # для жанров занижаем долю комедий
      if category_name == 'genre'
        stats.map! do |genre|
          if genre[0] == 'Комедия'
            [genre[0], genre[1]*0.6]
          else
            genre
          end
        end
      end
      max = stats.max {|l,r| l[1] <=> r[1] }[1]
      min = stats.min {|l,r| l[1] <=> r[1] }[1]

      stats.map do |category|
        {
          category: category[0],
          percent: category[1],
          scale: max == min ? 1 : ((category[1]-min)/(max-min)*4).round(0).to_i
        }
      end
    else
      stats
    end
  end
end
