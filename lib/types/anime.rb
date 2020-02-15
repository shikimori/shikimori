module Types
  module Anime
    KINDS = %i[tv movie ova ona special music]
    STATUSES = %i[anons ongoing released]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)

    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*STATUSES)

    Rating = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:none, :g, :pg, :pg_13, :r, :r_plus, :rx)

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
