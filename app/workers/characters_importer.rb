class CharactersImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  queue: :slow_parsers,
                  retry: false

  def do
    CharacterMalParser.import
  end
end
