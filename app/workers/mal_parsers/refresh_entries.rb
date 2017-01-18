class MalParsers::RefreshEntries
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :mal_parsers
  )

  TYPES = Types::Strict::String.enum('anime', 'manga')

  def perform type, status, refresh_interval
    klass = TYPES[type].classify.constantize

    Import::Refresh.call(
      klass,
      ids(klass, status),
      refresh_interval.to_i.seconds
    )
  end

private

  def ids klass, status
    AnimeStatusQuery
      .new(klass.all)
      .by_status(status)
      .order(:id)
      .pluck(:id)
  end
end
