class Types::Scalars::RatingString < GraphQL::Types::String
  description(
    "List of values separated by comma.\n\n" +
      I18n.t('enumerize.anime.rating.hint', locale: :en)
        .map do |key, description|
          "`#{key}` - #{description}\n\n" \
            "`!#{key}` - Exclude \"#{description}\""
        end
        .join("\n\n")
  )
end
