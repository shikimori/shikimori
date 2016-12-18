class MalParsers::FetchEntry
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :mal_parsers
  )

  def perform id, type
  end
end
