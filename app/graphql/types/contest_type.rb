class Types::ContestType < Types::BaseObject
  include Types::Concerns::DescriptionFields

  field :id, GraphQL::Types::ID, null: false

  field :rounds, [Types::ContestRoundType], null: false, complexity: 2

  field :name, String, null: false
  def name
    object.title_ru
  end
  field :member_type, Types::Enums::Contest::MemberTypeEnum, null: false
  field :strategy_type, Types::Enums::Contest::StrategyTypeEnum, null: false
  field :state, Types::Enums::Contest::StateEnum, null: false

  field :started_on, GraphQL::Types::ISO8601Date
  field :finished_on, GraphQL::Types::ISO8601Date

  field :matches_per_round, Integer
  field :match_duration, Integer
  field :matches_interval, Integer

private

  def decorated_object
    @decorated_object ||= object.decorate
  end
end
