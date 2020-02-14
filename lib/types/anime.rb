module Types
  module Anime
    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anons, :ongoing, :released)

    Rating = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:none, :g, :pg, :pg_13, :r, :r_plus, :rx)

    Duration = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:S, :D, :F)

    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:anons, :ongoing, :released, :planned, :latest)

    OPTIONS = %i[
      strict_torrent_name_match
      disabled_torrents_sync
      disabled_anime365_sync
    ]

    Options = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*OPTIONS)
  end
end
