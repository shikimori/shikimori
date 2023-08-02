class Types::CharacterRoleType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :roles, [String]
  field :character, Types::CharacterType
end
