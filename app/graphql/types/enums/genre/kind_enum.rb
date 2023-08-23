class Types::Enums::Genre::KindEnum < GraphQL::Schema::Enum
  graphql_name 'GenreKindEnum'

  Types::GenreV2::Kind.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.genre_v2.kind.#{key}", locale: :en)
  end
end
