class Types::CharacterRoleType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :character, Types::CharacterType

  field :roles_ru, [String]
  def roles_ru
    object.roles.map { |role| I18n.t "role.#{role}", default: role }
  end

  field :roles_en, [String]
  def roles_en
    object.roles
  end
end
