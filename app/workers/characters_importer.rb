class CharactersImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def do
    CharacterMalParser.import
  end
end
