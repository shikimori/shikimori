module Types
  module Collection
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anime, :manga, :ranobe, :character, :person)

    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:unpublished, :private, :hidden, :published)
  end
end
