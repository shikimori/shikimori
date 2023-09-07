class Types::PersonRoleType < Types::BaseObject
  field :id, ID, null: false
  field :person, Types::PersonType, null: false

  field :roles_ru, [String], null: false
  def roles_ru
    object.roles.map { |role| I18n.t "role.#{role}", default: role }
  end

  field :roles_en, [String], null: false
  def roles_en
    object.roles
  end
end
