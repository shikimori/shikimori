module Types
  module Genre
    ENTRY_TYPES = %w[Anime Manga]
    EntryType = Types::String.enum(*ENTRY_TYPES)
  end
end
