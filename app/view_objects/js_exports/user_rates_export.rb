class JsExports::UserRatesExport
  include Singleton

  KINDS = %i(catalog_entry user_rate)
  DELIMITER = ':'
  PLACEHOLDERS = /
    data-track_user_rate="
      ( #{KINDS.join '|'} )
        #{DELIMITER}
      ( anime|manga )
        #{DELIMITER}
      ( \d+ )
    "
  /mix

  def placeholder kind, entry
    raise ArgumentError, "unknown kind: #{kind}" unless KINDS.include?(kind)

    [
      kind,
      entry.anime? ? :anime : :manga,
      entry.id
    ].join(DELIMITER)
  end

  def sweep html
    cleanup
    html.scan(PLACEHOLDERS) do |results|
      track results[0].to_sym, results[1].to_sym, results[2].to_i
    end
  end

  def export user, _ability
    anime_rates = user_rates ids(:anime), Anime, user
    manga_rates = user_rates ids(:manga), Manga, user

    KINDS.each_with_object({}) do |kind, memo|
      memo[kind] =
        anime_rates.select { |v| cache[kind][:anime].include? v.target_id } +
          manga_rates.select { |v| cache[kind][:manga].include? v.target_id }

      memo[kind] = memo[kind].map { |rate| UserRateSerializer.new rate }
    end
  end

private

  def track kind, type, id
    cache[kind][type] << id
  end

  def cleanup
    Thread.current[self.class.name] = empty_cache_value
  end

  def cache
    Thread.current[self.class.name] ||= empty_cache_value
  end

  def ids type
    KINDS.flat_map { |kind| cache[kind][type] }
  end

  def empty_cache_value
    KINDS.each_with_object({}) do |kind, memo|
      memo[kind] = { anime: [], manga: [] }
    end
  end

  def user_rates entry_ids, klass, user
    return [] unless entry_ids.any?

    UserRate
      .where(user: user)
      .where(target_type: klass.name)
      .where(target_id: entry_ids)
      .sort_by(&:id)
  end
end
