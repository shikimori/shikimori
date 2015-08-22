class CharactersImporter
  include Sidekiq::Worker
  sidekiq_options(
    unique: true,
    queue: :slow_parsers,
    retry: false
  )

  def perform
    CharacterMalParser.import
  end
end
