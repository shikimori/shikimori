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

  SLICE_SIZE = 5000
  JOIN_ASSOCIATION = {
    anime: :anime,
    manga: :manga
  }
  INTERVALS = 10

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

    durations
  end

  def fetch_slice iteration
    @scope
      .joins(JOIN_ASSOCIATION[type])
      .where.not(user_id: User.excluded_from_statistics.select('id'))
      .where(user_id: (iteration * SLICE_SIZE)..((iteration + 1) * SLICE_SIZE))
      .group('user_id')
      .pluck(Arel.sql(SELECT_SQL))
  end

  def spawn_intervals stats
    data = confidence_interval(stats.sort)

    1.upto(INTERVALS).map do |i|
      round_up(data[data.size * i / (INTERVALS + 1)])
    end
  end

  def fill_intervals intervals, stats
    stats.each_with_object(intervals_hash(intervals)) do |duration, memo|

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
    User.order(id: :desc).limit(1).pluck(:id)
  end

  def cache_key iteration
    [Digest::MD5.hexdigest(@scope.to_sql), iteration, :v8]
  end

  def confidence_interval stats
    stats[(stats.size * 0.05)..(stats.size * 0.95)]
  end
end

# Rails.logger = ActiveSupport::Logger.new(STDOUT)
# Dalli.logger = Rails.logger
# ActiveRecord::Base.logger = Rails.logger
#
# scope = UserRate.where(target_type: 'Anime'); z = DbStatistics::ListDuration.call(scope, :anime)
