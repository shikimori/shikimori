class Recommendations::EntriesFetcher
  def initialize klass
    @klass = klass
  end

  def fetch
    @fetch ||= Rails.cache.fetch cache_key, expires_in: 2.weeks do
      @klass
        .where.not(kind: %i[special music])
        .select(%i[id score])
        .each_with_object({}) do |v, memo|
          memo[v.id] = v
        end
    end
  end

  def ids
    @ids ||= Set.new fetch.keys
  end

  def cache_key
    [:all_entries, @klass.name, @klass.count, @klass.last.id]
  end
end
