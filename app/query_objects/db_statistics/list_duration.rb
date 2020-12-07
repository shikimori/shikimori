class DbStatistics::ListDuration
  method_object :scope, :type

  CACHE_VERSION = :v10

  Type = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:anime, :manga)

  CHAPTER_DURATION = Manga::CHAPTER_DURATION
  VOLUME_DURATION = Manga::VOLUME_DURATION

  SELECT_SQL = {
    anime: (
      <<~SQL.squish
        sum(
          (case
            when user_rates.status in (
              #{UserRate.status_id :completed}, #{UserRate.status_id :rewatching}
            ) then
              greatest(animes.episodes, animes.episodes_aired)
            else
              user_rates.episodes
          end) * animes.duration
        ) as total_duration
      SQL
    ),
    manga: <<~SQL.squish
      greatest(
        sum(
          (case
            when user_rates.status in (
              #{UserRate.status_id :completed}, #{UserRate.status_id :rewatching}
            ) then
              mangas.volumes
            else
              user_rates.volumes
          end) * #{VOLUME_DURATION}
        ),
        sum(
          (case
            when user_rates.status in (
              #{UserRate.status_id :completed}, #{UserRate.status_id :rewatching}
            ) then
              mangas.chapters
            else
              user_rates.chapters
          end) * #{CHAPTER_DURATION}
        )
      ) as total_duration
    SQL
  }

  JOIN_ASSOCIATION = {
    Type[:anime] => :anime,
    Type[:manga] => :manga
  }

  INTERVALS = [
    15,
    30,
    40,
    50,
    69,
    85,
    90,
    93,
    95,
    97,
    99,
    99.5
  ]

  FINAL_INTERVAL = 99_999_999
  SLICE_SIZE = 5000

  def call
    stats = fetch

    transform_keys fill_intervals(spawn_intervals(stats), stats)
  end

private

  def transform_keys stats # rubocop:disable AbcSize
    stats.transform_keys.with_index do |key, index|
      days = index == stats.size - 1 ?
        (stats.keys[-2] / 360.0).ceil :
        (key / 360.0).ceil

      if index.zero?
        "#{days}-"
      elsif index == stats.size - 1
        "#{days}+"
      else
        prior_days = (stats.keys[index - 1] / 360.0).ceil + 1
        "#{prior_days}-#{days}"
      end
    end
  end

  def fetch
    durations = []

    0.upto(iterations) do |iteration|
      slice = Rails.cache.fetch cache_key(iteration), expires_in: 1.day do
        fetch_slice iteration
      end

      slice.select { |v| v >= 360 }.each { |v| durations.push v }
    end

    durations.sort
  end

  def fetch_slice iteration
    @scope
      .joins(JOIN_ASSOCIATION[Type[@type]])
      .where.not(user_id: User.excluded_from_statistics.select('id'))
      .where(user_id: (iteration * SLICE_SIZE)..((iteration + 1) * SLICE_SIZE))
      .group('user_id')
      .pluck(Arel.sql(SELECT_SQL[Type[@type]]))
  end

  def spawn_intervals stats
    intervals = INTERVALS.map do |percent|
      round_up(stats[stats.size * percent / 100])
    end

    intervals.push FINAL_INTERVAL
  end

  def fill_intervals intervals, stats
    stats.each_with_object(intervals_hash(intervals)) do |value, memo|
      intervals.each do |interval|
        next if value >= interval

        memo[interval] += 1
        break
      end
    end
  end

  def intervals_hash intervals
    intervals.each_with_object({}) do |interval, memo|
      memo[interval] = 0
    end
  end

  def round_up number
    digits = number.to_s.size

    case digits
      when 1 then number
      when 2 then (number / 10.0).ceil * 10
      when 3, 4 then (number / 100.0).round * 100
      when 5 then (number / 1000.0).round * 1000
      when 6 then (number / 10_000.0).round * 10_000
      else (number / 100_000.0).round * 100_000
    end
  end

  def iterations
    max_id / SLICE_SIZE
  end

  def max_id
    User.order(id: :desc).limit(1).pluck(:id).first
  end

  def cache_key iteration
    [Digest::MD5.hexdigest(@scope.to_sql), iteration, CACHE_VERSION]
  end
end
