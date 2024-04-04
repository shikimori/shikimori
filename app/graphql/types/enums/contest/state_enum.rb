class Types::Enums::Contest::StateEnum < GraphQL::Schema::Enum
  graphql_name 'ContestStateEnum'

  Contest.aasm.states.map(&:name).each do |key|
    value key, key
  end
end
