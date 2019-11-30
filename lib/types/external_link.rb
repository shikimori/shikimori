module Types
  module ExternalLink
    SOURCES = %i[shikimori myanimelist smotret_anime hidden]

    Source = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*SOURCES)

    COMMON_KINDS = %i[official_site wikipedia anime_news_network myanimelist]

    KINDS = {
      anime: COMMON_KINDS + %i[
        anime_db
        world_art
        kage_project
        smotret_anime
        wakanim
        crunchyroll
        youtube
        netflix
        hulu
        amazon
      ],
      manga: COMMON_KINDS + %i[
        readmanga
        mangaupdates
        mangafox
        mangachan
        mangahub
      ],
      ranobe: COMMON_KINDS + %i[ruranobe novelupdates]
    }

    INVISIBLE_KINDS = %i[myanimelist smotret_anime mangachan]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS.values.flatten.uniq)
  end
end
