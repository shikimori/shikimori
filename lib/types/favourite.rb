module Types
  module Favourite
    KINDS = %i[
      common
      seyu
      mangaka
      producer
      person
    ]
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)

    LINKED_TYPES = %w[
      Anime
      Manga
      Ranobe
      Person
      Character
    ]
    LinkedType = Types::String.enum(*LINKED_TYPES)
  end
end
