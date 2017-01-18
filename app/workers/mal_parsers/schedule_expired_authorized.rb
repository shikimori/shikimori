class MalParsers::ScheduleExpiredAuthorized
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(_args) { 'only_one_task' },
    queue: :mal_parsers
  )

  def perform status, expiration_interval
    anime_ids(status, expiration_interval).each do |anime_id|
      MalParsers::FetchEntryAuthorized.perform_async(anime_id)
    end
  end

  private

  def anime_ids status, expiration_interval
    AnimeStatusQuery
      .new(Anime)
      .by_status(status)
      .where(
        'analyzed_imported_at IS NULL OR analyzed_imported_at < ?',
        expiration_interval.ago
      )
      .where.not(mal_id: nil)
      .order(:id)
      .pluck(:id)
  end
end
