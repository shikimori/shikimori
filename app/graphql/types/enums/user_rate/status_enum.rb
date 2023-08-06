class Types::Enums::UserRate::StatusEnum < GraphQL::Schema::Enum
  graphql_name 'UserRateStatusEnum'

  I18n.with_locale :en do
    Types::UserRate::Status.values.each do |key| # rubocop:disable Style/HashEachMethods
      value key, UserRate.status_name(key, Anime.name)
    end
  end
end
