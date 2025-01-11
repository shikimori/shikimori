module Types
  module Anime
    KINDS = %i[tv movie ova ona special tv_special music pv cm]
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)

    STATUSES = %i[anons ongoing released]
    Status = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*STATUSES)

    Rating = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:none, :g, :pg, :pg_13, :r, :r_plus, :rx)

    ORIGINS = %i[
      original
      manga
      web_manga
      four_koma_manga
      novel
      web_novel
      visual_novel
      light_novel
      game
      card_game
      music
      radio
      book
      picture_book
      mixed_media
      other
      unknown
    ]
    Origin = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ORIGINS)

    OPTIONS = %w[
      strict_torrent_name_match
      disabled_torrents_sync
      disabled_anime365_sync
    ]
    Options = Types::Strict::String
      .constructor(&:to_s)
      .enum(*OPTIONS)
  end
end
