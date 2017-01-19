module Types
  module ExternalLink
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i(official_site anime_db anime_news_network wikipedia))
  end
end
