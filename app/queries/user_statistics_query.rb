class UserStatisticsQuery
  attr_reader :anime_rates, :anime_valuable_rates
  attr_reader :manga_rates, :manga_valuable_rates
  attr_reader :genres, :studios, :publishers

  # стандартный формат дат для сравнения
  DateFormat = "%Y-%m-%d"

  def initialize user
    @user = user
    @preferences = user.preferences

    @seasons = AniMangaSeason.catalog_seasons
    @genres, @studios, @publishers = AniMangaAssociationsQuery.new.fetch

    @anime_rates = @user
      .anime_rates
      .joins('join animes on animes.id = target_id')
      .select('user_rates.*, animes.rating, animes.kind, animes.duration, animes.episodes as entry_episodes, animes.episodes_aired as entry_episodes_aired')
      .each do |v|
        v[:rating] = I18n.t("RatingShort.#{v[:rating]}") if v[:rating] != 'None'
      end

    @anime_valuable_rates = @anime_rates.select {|v| v.completed? || v.watching? || v.rewatching? }
    @anime_history = @user
      .history
      .where(target_type: Anime.name)
      .where("action in (?) or (action = ? and value in (?))",
              [UserHistoryAction::Episodes, UserHistoryAction::CompleteWithScore],
              UserHistoryAction::Status,
              [UserRate.statuses[:completed].to_s, UserRate.statuses[:rewatching].to_s])
    #@imports = @user.history.where(action: [UserHistoryAction::MalAnimeImport, UserHistoryAction::ApAnimeImport, UserHistoryAction::MalMangaImport, UserHistoryAction::ApMangaImport])

    @manga_rates = @user
      .manga_rates
      .joins('join mangas on mangas.id = target_id')
      .select("user_rates.*, mangas.rating, #{Manga::DURATION} as duration, mangas.kind, mangas.chapters as entry_episodes, 0 as entry_episodes_aired")
      .each do |v|
        v[:rating] = I18n.t("RatingShort.#{v[:rating]}") if v[:rating] != 'None'
      end
    @manga_valuable_rates = @manga_rates.select {|v| v.completed? || v.watching? || v.rewatching? }
    @manga_history = @user
      .history
      .where(target_type: Manga.name)
      .where("action in (?) or (action = ? and value in (?))",
              [UserHistoryAction::Chapters, UserHistoryAction::CompleteWithScore],
              UserHistoryAction::Status,
              [UserRate.statuses[:completed].to_s, UserRate.statuses[:rewatching].to_s])
  end

  # статистика активности просмотра аниме / чтения манги
  def by_activity(intervals)
    ##[
      ##{type: :anime, rates: @anime_rates, histories: @anime_history},
      ##{type: :manga, rates: @manga_rates, histories: @manga_history}
    ##].each_with_object({}) do |stat, rez|
      ##rez[stat[:type]] = compute_by_activity stat[:type].to_s, stat[:rates], stat[:histories], intervals
    ##end
    #{
      #stats: compute_by_activity(@anime_rates, @manga_rates, @anime_history, @manga_history, intervals)
    #}
    compute_by_activity(@anime_rates, @manga_rates, @anime_history, @manga_history, intervals)
  end

  # вычисление статистики активности просмотра аниме / чтения манги
  def compute_by_activity(anime_rates, manga_rates, anime_histories, manga_histories, intervals)
    histories = anime_histories + manga_histories
    rates = anime_rates + manga_rates
    return {} if histories.empty?

    # минимальная дата старта статистики
    histories.select! { |v| v.created_at >= @preferences.statistics_start_on } if @preferences.statistics_start_on

    imported = Set.new histories
      .select {|v| v.action == UserHistoryAction::Status || v.action == UserHistoryAction::CompleteWithScore}
      .group_by {|v| v.updated_at.strftime DateFormat }
      .select {|k,v| v.size > 15 }
      .values.flatten
      .map(&:id)

    # заполняем кеш начальными данными
    cache = rates.each_with_object({}) do |v,rez|
      rez["#{v.target_id}#{v.target_type}"] = {
        duration: v[:duration],
        completed: 0,
        episodes: v[:entry_episodes] > 0 ? v[:entry_episodes] : v[:entry_episodes_aired]
      }
    end
    cache_keys = Set.new cache.keys

    # исключаем импортированное
    histories = histories.select { |v| !imported.include?(v.id) }
    # исключаем то, для чего rates нет, т.е. впоследствии удалённое из списка
    histories = histories.select { |v| cache_keys.include?("#{v.target_id}#{v.target_type}") }
    return {} if histories.empty?

    start_date = histories.map { |v| v.created_at }.min.to_datetime
    end_date = histories.map { |v| v.updated_at }.max.to_datetime

    distance = [(end_date.to_i - start_date.to_i) / intervals, 86400].max

    0.upto(intervals).map do |num|
      from = start_date + (distance*num).seconds
      to = from + distance.seconds - (num == intervals ? 0 : 1.second)

      next if from > DateTime.now || from > end_date + 1.hour

      history = histories.select { |v| v.updated_at >= from && v.updated_at < to }

      spent_time = 0

      #z=history
      #1/0 if num == 42
      #1/0 if z.any? && z.first.id != 3585457 && z.first.id != 3585459

      history.each do |entry|
        cached = cache["#{entry.target_id}#{entry.target_type}"]

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
    statuses @anime_rates, is_full
  end

  def manga_statuses is_full
    statuses @manga_rates, is_full
  end

  def statuses rates, is_full
    UserRate.statuses.map do |status_name, status_id|
      next if !is_full && status_name == 'rewatching'
      {
        id: status_id,
        grouped_id: !is_full && status_name == 'watching' ? "#{status_id},#{UserRate.statuses.find {|k,v| k == 'rewatching'}.second}" : status_id,
        name: status_name,
        size: !is_full && status_name == 'watching' ?
          rates.select {|v| v.watching? || v.rewatching? }.size :
          rates.select {|v| v.status == status_name }.size
      }
    end.compact
  end

  # статистика по статусам аниме и манги в списке пользователя
  def by_statuses
    data = [
      @preferences.anime_in_profile? ? [Anime.name, anime_statuses(false)] : nil,
      @preferences.manga_in_profile? ? [Manga.name, manga_statuses(false)] : nil
    ].compact

    data = data.map do |klass,stat|
      total = stat.sum {|v| v[:size] }
      completed = stat.select {|v| v[:id] == UserRate.statuses[:completed] }.sum {|v| v[:size] }
      dropped = stat.select {|v| v[:id] == UserRate.statuses[:dropped] }.sum {|v| v[:size] }
      incompleted = stat.select {|v| v[:id] != UserRate.statuses[:completed] && v[:id] != UserRate.statuses[:dropped] }.sum {|v| v[:size] }

      [
        klass,
        stat,
        {
          total: total,

          completed: completed,
          dropped: dropped,
          incompleted: incompleted,

          completed_percent: completed * 100.0 / total,
          dropped_percent: dropped * 100.0 / total,
          incompleted_percent: incompleted * 100.0 / total,
        }
      ]
    end

    data = data.select do |klass,stat,graph|
      stat.any? {|v| v[:size] > 0 }
    end

    data.each do |klass,stat,graph|
      other_stat = data.select { |_klass,_stat,_graph| _klass != klass }

      graph[:scale] = if data.size == 1 || other_stat.sum {|_klass,_stat,_graph| _graph[:total] } == 0
        1.0
      else
        other_total = other_stat[0][2][:total]
        [other_total > 0 ? graph[:total]*1.0 / other_total : 0, 1.0].min
      end
    end
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

    stats = sum > 8 ? stats_by_categories.map do |k,v|
      [k, ((v * 1000 / sum).to_i / 10.0).to_f]
    end.compact.sort_by {|k,v| k.name } : []

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
