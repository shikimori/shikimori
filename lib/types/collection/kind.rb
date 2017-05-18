module Types
  module Collection
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anime, :manga, :ranobe, :character, :person)
  end
end
