class Types::Enums::Manga::StatusEnum < GraphQL::Schema::Enum
  graphql_name 'MangaStatusEnum'

  Types::Manga::Status.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.manga.status.#{key}", locale: :en)
  end
end
