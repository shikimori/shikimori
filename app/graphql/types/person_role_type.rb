class Types::PersonRoleType < Types::BaseObject
  field :roles, [String]
  field :person, Types::PersonType
end
