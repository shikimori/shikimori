class Types::Enums::Anime::OriginEnum < GraphQL::Schema::Enum
  graphql_name 'AnimeOriginEnum'

  Types::Anime::Origin.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.anime.origin.#{key}", locale: :en)
  end
end
