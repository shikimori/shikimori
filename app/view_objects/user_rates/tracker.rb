class UserRates::Tracker < ViewObjectBase
  include Singleton

  PLACEHOLDERS = %r{data-track_user_rates="(anime-\d+|manga-\d+)"}i

  def placeholder entry
    "#{entry.anime? ? :anime : :manga}-#{entry.id}"
  end

  def sweep html
    cleanup
    html.scan(PLACEHOLDERS).each do |results|
      track results[0]
    end
    html
  end

  def export user
    user_rates(anime_ids, Anime, user) +
      user_rates(manga_ids, Manga, user)
  end

private

  def track entry
    cache << entry
  end

  def cache
    Thread.current[self.class.name] ||= []
  end

  def anime_ids
    cache
      .select { |v| v.starts_with? 'anime' }
      .map { |v| v.split('-').last.to_i }
  end

  def manga_ids
    cache
      .select { |v| v.starts_with? 'manga' }
      .map { |v| v.split('-').last.to_i }
  end

  def cleanup
    Thread.current[self.class.name] = []
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
