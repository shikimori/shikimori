class DbStatistics::ListDuration
  include ActionView::Helpers::NumberHelper
  method_object :scope, :type

  SELECT_SQL = <<~SQL.squish
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

  JOIN_ASSOCIATION = {
    anime: :anime,
    manga: :manga
  }

  INTERVALS = [
    10,
    20,
    30,
    40,
    50,
    69,
    85,
    93,
    97,
    99.5
  ]

  FINAL_INTERVAL = 99_999_999
  SLICE_SIZE = 5000

  CACHE_VERSION = :v_15

  def call
    stats = fetch

    fill_intervals spawn_intervals(stats), stats
  end

private

  def fetch
    durations = []

    0.upto(iterations) do |iteration|
      slice = Rails.cache.fetch cache_key(iteration) do
        fetch_slice iteration
      end

      slice.select { |v| v >= 60 }.each { |v| durations.push v }
    end

    durations.sort
  end

  def fetch_slice iteration
    @scope.
      joins(JOIN_ASSOCIATION[type]).
      where.not(user_id: User.excluded_from_statistics.select('id')).
      where(user_id: (iteration * SLICE_SIZE)..((iteration + 1) * SLICE_SIZE)).
      group('user_id').
      pluck(Arel.sql(SELECT_SQL))
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

if Rails.env.production?
  Rails.logger = ActiveSupport::Logger.new(STDOUT)
  Dalli.logger = Rails.logger
  ActiveRecord::Base.logger = Rails.logger

  scope = UserRate.where(target_type: 'Anime'); z = DbStatistics::ListDuration.call(scope, :anime)
end
