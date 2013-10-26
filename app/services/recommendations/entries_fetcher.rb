class Recommendations::EntriesFetcher
  def initialize(klass)
    @klass = klass
  end

  def fetch
    @data ||= Rails.cache.fetch "all_entries_#{@klass.name}_#{@klass.last.id}", expires_in: 2.weeks do
      @klass
          .where { kind != 'Special' }
          .select([:id, :score])
          .each_with_object({}) { |v,memo| memo[v.id] = v }
    end
  end

  def ids
    @ids ||= Set.new fetch.keys
  end
end
