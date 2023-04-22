module Types
  module Genre
    ENTRY_TYPES = %w[Anime Manga]
    EntryType = Types::String.enum(*ENTRY_TYPES)

    KINDS = %i[
      genre
      demographic
      theme
    ]
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)
  end
end
