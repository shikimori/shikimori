class Types::Enums::ContestMatch::StateEnum < GraphQL::Schema::Enum
  graphql_name 'ContestMatchStateEnum'

  ContestMatch.aasm.states.map(&:name).each do |key|
    value key, key
  end
end
