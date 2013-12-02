class VerifyCharactersJob
  def perform
    CharacterMalParser.import bad_entries if bad_entries.any?
    raise "Broken characters found: #{bad_entries.join ', '}" if bad_entries.any?
  end

  def bad_entries
    Character.where(name: nil).pluck :id
  end
end
