class Types::Scalars::DurationString < GraphQL::Types::String
  description(
    "List of values separated by comma.\n\n" +
      I18n.t('animes_collection.menu.anime.duration', locale: :en)
        .map do |key, description|
          "`#{key}` - #{description}\n\n" \
            "`!#{key}` - Exclude \"#{description}\""
        end
        .join("\n\n")
  )
end
