class MalParsers::RefreshEntries
  include Sidekiq::Worker
  sidekiq_options queue: :mal_parsers

  TYPES = Types::Strict::String
    .enum('anime', 'manga', 'character', 'person')

  def perform type, status, refresh_interval
    klass = TYPES[type].classify.constantize

    DbImport::Refresh.call(
      klass,
      ids(klass, status),
      refresh_interval.to_i.seconds
    )
  end

private

  def ids klass, status
    return klass.all unless status

    Animes::Query.new(klass.all)
      .by_status(status)
      .order(:id)
      .pluck(:id)
  end
end
