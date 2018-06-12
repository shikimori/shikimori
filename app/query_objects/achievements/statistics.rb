class Achievements::Statistics
  method_object :neko_id, :level

  CACHE_KEY = 'neko_statistics'

  def call
    return unless cache.dig(neko_id, level)

    Neko::Statistics.new cache[neko_id][level]
  end

private

  def neko_id
    @neko_id.to_sym
  end

  def level
    @level.to_s.to_sym
  end

  def cache
    @cache ||= JSON.parse(
      Rails.application.redis.get(CACHE_KEY) || '{}',
      symbolize_names: true
    )
  end
end
