class Types::Enums::UserRate::OrderFieldEnum < GraphQL::Schema::Enum
  graphql_name 'UserRateOrderFieldEnum'

  %i[id updated_at].each do |key|
    value key, "By #{key}"
  end
end
