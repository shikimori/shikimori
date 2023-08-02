class Types::Enums::Manga::KindEnum < GraphQL::Schema::Enum
  graphql_name 'MangaKindEnum'

  Types::Manga::Kind.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.manga.kind.#{key}", locale: :en)
  end
end
