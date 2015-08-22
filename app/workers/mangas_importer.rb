class MangasImporter
  include Sidekiq::Worker
  sidekiq_options(
    unique: true,
    queue: :slow_parsers,
    retry: false
  )

  def perform
    MangaMalParser.import
  end
end
