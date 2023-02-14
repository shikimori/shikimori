class MalParsers::ScheduleExpiredAuthorized
  include Sidekiq::Worker
  sidekiq_options queue: :mal_parsers

  SCHEDULE_INTERVAL = 10.minutes

  ANONS_EXPIRATION_INTERVAL = 1.month
  ONGOING_EXPIRATION_INTERVAL = 1.month
  DEFAULT_EXPIRATION_INTERVAL = 6.months

  def perform
    anime_ids = all_anime_ids
    manga_ids = all_manga_ids(anime_ids)

    schedule anime_ids, Anime, 0
    schedule manga_ids, Manga, anime_ids.size
  end

private

  def schedule entry_ids, klass, offset
    entry_ids.each_with_index do |entry_id, index|
      MalParsers::FetchEntryAuthorized.perform_in(
        (offset + index) * SCHEDULE_INTERVAL,
        entry_id,
        klass.name
      )
    end
  end

  def all_anime_ids
    [anons_anime_ids, ongoing_anime_ids, other_anime_ids]
      .flatten
      .uniq
      .take(max_entries_to_schedule)
  end

  def all_manga_ids anime_ids
    filtered_entries(DEFAULT_EXPIRATION_INTERVAL, Manga)
      .pluck(:id)
      .take(max_entries_to_schedule - anime_ids.size)
  end

  def anons_anime_ids
    filtered_entries(ANONS_EXPIRATION_INTERVAL, Anime)
      .where(status: :anons)
      .pluck(:id)
  end

  def ongoing_anime_ids
    filtered_entries(ONGOING_EXPIRATION_INTERVAL, Anime)
      .where(status: :ongoing)
      .pluck(:id)
  end

  def other_anime_ids
    filtered_entries(DEFAULT_EXPIRATION_INTERVAL, Anime)
      .where.not(status: %i[anons ongoing])
      .pluck(:id)
  end

  def filtered_entries expiration_interval, klass
    klass
      .where(
        'authorized_imported_at IS NULL OR authorized_imported_at < ?',
        expiration_interval.ago
      )
      .where.not(mal_id: nil)
      .order(:ranked)
  end

  def max_entries_to_schedule
    (0.9 * (1.day / SCHEDULE_INTERVAL.to_f)).floor
  end
end
