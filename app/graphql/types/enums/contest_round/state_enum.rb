class Types::Enums::ContestRound::StateEnum < GraphQL::Schema::Enum
  graphql_name 'ContestRoundStateEnum'

  ContestRound.aasm.states.map(&:name).each do |key|
    value key, key
  end
end
