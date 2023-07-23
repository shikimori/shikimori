class Types::Scalars::IncompleteDate < Types::BaseObject
  field :year, Int
  field :month, Int
  field :day, Int
  field :date, GraphQL::Types::ISO8601Date
end
