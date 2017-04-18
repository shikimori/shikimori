module Types
  module Collection
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anime, :manga, :character, :person)
  end
end
