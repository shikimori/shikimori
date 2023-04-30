module Types
  module GenreV2
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
