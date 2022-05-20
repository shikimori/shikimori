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

    options_list = %i[
      strict_torrent_name_match
      disabled_torrents_sync
      disabled_anime365_sync
    ]

    # entry rates from 1 to 10
    (1..10).each do |score|
      # possible percentages to filter
      (1..100).each do |percent|
        options_list << "score_filter_#{score}_#{percent}"
      end
    end

    Options = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*options_list)
  end
end
