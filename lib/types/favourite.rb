module Types
  module Favourite
    KINDS = %i[
      seyu
      mangaka
      producer
      person
    ]
    Kinds = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)

    LINKED_TYPES = %w[
      Anime
      Manga
      Ranobe
      Person
      Character
    ]
    LinkedTypes = Types::String.enum(*LINKED_TYPES)
  end
end
