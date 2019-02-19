class MalParsers::ScheduleMissing
  include Sidekiq::Worker
  sidekiq_options queue: :mal_parsers

  TYPES = Types::Coercible::String.enum('anime', 'manga', 'character', 'person')

  def perform type
    TYPES[type].classify.constantize
      .where(mal_id: nil)
      .order(:id)
      .each { |entry| MalParsers::FetchEntry.perform_async entry.id, type }
  end
end
