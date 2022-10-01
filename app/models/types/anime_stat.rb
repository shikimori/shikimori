module Types
  module AnimeStat
    EntryType = Types::Strict::String
      .constructor(&:to_s)
      .enum('Anime', 'Manga')
  end
end
