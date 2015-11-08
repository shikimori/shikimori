class AnimesImporter
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :slow_parsers,
    retry: false
  )

  def perform
    AnimeMalParser.import
  end
end
