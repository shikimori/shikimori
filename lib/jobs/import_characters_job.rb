class ImportCharactersJob < JobWithRestart
  def do
    CharacterMalParser.import
  end
end
