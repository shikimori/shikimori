class Types::Enums::Contest::StrategyTypeEnum < GraphQL::Schema::Enum
  graphql_name 'ContestStrategyTypeEnum'

  Types::Contest::StrategyType.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.contest.strategy_type.#{key}", locale: :en)
  end
end
