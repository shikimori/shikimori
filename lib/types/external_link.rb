module Types
  module ExternalLink
    SOURCES = %i[myanimelist shikimori]

    Source = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*SOURCES)

    COMMON_KINDS = %i[official_site wikipedia anime_news_network myanimelist]

    KINDS = {
      anime: COMMON_KINDS + %i[anime_db world_art kage_project],
      manga: COMMON_KINDS + %i[
        readmanga
        mangaupdates
        mangafox
        mangachan
        mangahub
      ],
      ranobe: COMMON_KINDS + %i[ruranobe novelupdates]
    }

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS.values.flatten.uniq)
  end
end
