class MalParsers::ScheduleExpiredAuthorized
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executing,
    queue: :mal_parsers
  )

  SCHEDULE_INTERVAL = 10.minutes

  ANONS_EXPIRATION_INTERVAL = 1.month
  ONGOING_EXPIRATION_INTERVAL = 1.month
  DEFAULT_EXPIRATION_INTERVAL = 6.months

  def perform
    all_anime_ids.each_with_index do |anime_id, index|
      MalParsers::FetchEntryAuthorized.perform_in(
        index * SCHEDULE_INTERVAL,
        anime_id
      )
    end
  end

  private

  def all_anime_ids
    [anons_anime_ids, ongoing_anime_ids, other_anime_ids]
      .flatten
      .take(max_animes_to_schedule)
  end

  def anons_anime_ids
    filtered_animes(ANONS_EXPIRATION_INTERVAL)
      .where(status: :anons)
      .pluck(:id)
  end

  def ongoing_anime_ids
    filtered_animes(ONGOING_EXPIRATION_INTERVAL)
      .where(status: :ongoing)
      .pluck(:id)
  end

  def other_anime_ids
    filtered_animes(DEFAULT_EXPIRATION_INTERVAL)
      .where.not(status: [:anons, :ongoing])
      .pluck(:id)
  end

  def filtered_animes expiration_interval
    Anime
      .where(
        'authorized_imported_at IS NULL OR authorized_imported_at < ?',
        expiration_interval.ago
      )
      .where.not(mal_id: nil)
      .order(:ranked)
  end

  def max_animes_to_schedule
    (0.9 * (1.day / SCHEDULE_INTERVAL)).floor
  end
end
