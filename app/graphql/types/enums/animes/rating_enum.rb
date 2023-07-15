class Types::Enums::Animes::RatingEnum < GraphQL::Schema::Enum
  I18n.t('enumerize.anime.rating.hint', locale: :en).each do |key, description|
    value key.to_s, description
    value "NOT_#{key}", "Exclude \"#{description}\""
  end
end
