class PeopleImporter
  include Sidekiq::Worker
  sidekiq_options(
    unique: true,
    queue: :slow_parsers,
    retry: false
  )

  def perform
    PersonMalParser.import
  end
end
