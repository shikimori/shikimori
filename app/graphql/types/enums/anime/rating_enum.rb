class Types::Enums::Anime::RatingEnum < GraphQL::Schema::Enum
  graphql_name 'AnimeRatingEnum'

  Types::Anime::Rating.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.anime.rating.#{key}", locale: :en)
  end
end
