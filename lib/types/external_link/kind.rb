module Types
  module ExternalLink
    Kind = Types::Strict::String.enum(
      *%w(
        official_site
        anime_db
        anime_news_network
        wikipedia
      )
    )
  end
end
