module Types
  module Manga
    KINDS = %i[manga manhwa manhua light_novel novel one_shot doujin]
    STATUSES = %i[anons ongoing released paused discontinued]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)

    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*STATUSES)
  end
end
