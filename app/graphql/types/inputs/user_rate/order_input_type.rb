class Types::Inputs::UserRate::OrderInputType < GraphQL::Schema::InputObject
  graphql_name 'UserRateOrderInputType'

  argument :field, Types::Enums::UserRate::OrderFieldEnum, required: true
  argument :order, Types::Enums::SortOrderEnum, required: true
end
