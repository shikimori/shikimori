class Types::Enums::Anime::KindEnum < GraphQL::Schema::Enum
  graphql_name 'AnimeKindEnum'

  Types::Anime::Kind.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.anime.kind.#{key}", locale: :en)
  end
end
