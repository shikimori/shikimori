class Types::Enums::Anime::StatusEnum < GraphQL::Schema::Enum
  graphql_name 'AnimeStatusEnum'

  Types::Anime::Status.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.anime.status.#{key}", locale: :en)
  end
end
