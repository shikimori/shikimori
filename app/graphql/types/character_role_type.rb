class Types::CharacterRoleType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :character, Types::CharacterType

  field :roles, [String]
  field :roles_russian, [String]
  def roles_russian
    object.roles.map { |role| I18n.t "role.#{role}", default: role }
  end
end
