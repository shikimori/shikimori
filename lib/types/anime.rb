module Types
  module Anime
    Duration = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:S, :D, :F)

    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anons, :ongoing, :released, :planned, :latest)

    OPTIONS = %i[
      disable_torrents_sync
      disable_anime365_sync
    ]

    Options = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*OPTIONS)
  end
end
