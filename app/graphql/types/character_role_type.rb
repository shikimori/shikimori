class Types::CharacterRoleType < Types::BaseObject
  field :id, ID, null: false
  field :character, Types::CharacterType, null: false

  field :roles_ru, [String], null: false
  def roles_ru
    object.roles.map { |role| I18n.t "role.#{role}", default: role }
  end

  field :roles_en, [String], null: false
  def roles_en
    object.roles
  end
end
