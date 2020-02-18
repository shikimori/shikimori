module Types
  module Manga
    KINDS = %i[manga manhwa manhua novel one_shot doujin]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)
  end
end
