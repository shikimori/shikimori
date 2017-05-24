module Types
  module ExternalLink
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i(
        official_site
        wikipedia
        anime_news_network
        anime_db
        kage_project
        ruranobe
      ))
  end
end
