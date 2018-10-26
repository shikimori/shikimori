class Achievements::Statistics
  method_object :neko_id, :level

  CACHE_KEY = 'neko_statistics'

  TOTAL_KEY = :total
  TOTAL_LEVEL = :'0'

  def call
    return unless cache.dig(neko_id, level)

    achievement_stats = cache[neko_id][level]
    total_stats = cache[TOTAL_KEY][TOTAL_LEVEL]

    Neko::Stats::INTERVALS.each_with_index.map do |interval, index|
      statistics achievement_stats, total_stats, interval, index
    end
  end

private

  def neko_id
    @neko_id.to_sym
  end

  def level
    @level.to_s.to_sym
  end

  def statistics achievement_stats, total_stats, interval, index
    {
      label: label(interval, index),
      users: achievement_stats.interval(index),
      percent: achievement_stats.interval(index).to_f /
        total_stats.interval(index)
    }
  end

  def label interval, index
    if interval == Neko::Stats::INTERVALS.last
      "#{Neko::Stats::INTERVALS[index - 1]}+"
    else
      "#{index.zero? ? 0 : Neko::Stats::INTERVALS[index - 1] + 1}-#{interval}"
    end
  end

  def cache
    @cache ||= PgCache.read(CACHE_KEY) || {}
  end
end
