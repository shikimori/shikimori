class MangasImporter
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :slow_parsers,
    retry: false
  )

  def perform
    MangaMalParser.import
  end
end
