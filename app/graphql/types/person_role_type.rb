class Types::PersonRoleType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :person, Types::PersonType

  field :roles_ru, [String]
  def roles_ru
    object.roles.map { |role| I18n.t "role.#{role}", default: role }
  end

  field :roles_en, [String]
  def roles_en
    object.roles
  end
end
