class MalParsers::ScheduleExpiredAuthorized
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executing,
    queue: :mal_parsers
  )

  SCHEDULE_INTERVAL = 10.minutes

  def perform status, expiration_interval
    anime_ids = anime_ids(status, expiration_interval)
    anime_ids.each_with_index do |anime_id, index|
      MalParsers::FetchEntryAuthorized.perform_in(
        index * SCHEDULE_INTERVAL,
        anime_id
      )
    end
  end

  private

  def anime_ids status, expiration_interval
    AnimeStatusQuery.new(Anime)
      .by_status(status)
      .where(
        'authorized_imported_at IS NULL OR authorized_imported_at < ?',
        expiration_interval.ago
      )
      .where.not(mal_id: nil)
      .order(:id)
      .pluck(:id)
      .take(max_animes_to_schedule)
  end

  def max_animes_to_schedule
    (0.9 * (1.day / SCHEDULE_INTERVAL)).floor
  end
end
