class Types::Enums::Genre::EntryTypeEnum < GraphQL::Schema::Enum
  graphql_name 'GenreEntryTypeEnum'

  Types::GenreV2::EntryType.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.genre_v2.entry_type.#{key}", locale: :en)
  end
end
