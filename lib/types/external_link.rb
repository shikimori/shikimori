module Types
  module ExternalLink
    SOURCES = %i[myanimelist shikimori]
    KINDS = %i[
      official_site
      wikipedia
      anime_news_network
      anime_db
      ruranobe
      readmanga
      myanimelist
      world_art
      kage_project
    ]

    Source = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*SOURCES)

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)
  end
end
