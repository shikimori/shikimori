class Types::Enums::Animes::KindEnum < GraphQL::Schema::Enum
  Types::Anime::Kind.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.anime.kind.#{key}", locale: :en)
  end
end
