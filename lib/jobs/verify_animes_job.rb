class VerifyAnimesJob
  def perform
    AnimeMalParser.import bad_entries if bad_entries.any?
    raise "Broken animes found: #{bad_entries.join ', '}" if bad_entries.any?
  end

  def bad_entries
    Anime.where(name: nil).pluck :id
  end
end
