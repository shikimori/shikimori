class MalParsers::ScheduleExpired
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :mal_parsers
  )

  TYPES = Types::Coercible::String.enum('anime', 'manga', 'character', 'person')

  def perform type
    TYPES[type].classify.constantize
      .where(imported_at: nil)
      .order(:id)
      .each { |entry| MalParsers::FetchEntry.perform_async entry.id, type }
  end
end
