class Types::Enums::Animes::StatusEnum < GraphQL::Schema::Enum
  Types::Anime::Status.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.anime.status.#{key}", locale: :en)
  end
end
