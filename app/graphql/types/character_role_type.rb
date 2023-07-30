class Types::CharacterRoleType < Types::BaseObject
  field :roles, [String]
  field :character, Types::CharacterType
end
