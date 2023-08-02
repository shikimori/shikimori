class Types::PersonRoleType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :roles, [String]
  field :person, Types::PersonType
end
