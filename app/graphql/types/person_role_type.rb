class Types::PersonRoleType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :person, Types::PersonType

  field :roles, [String]
  field :roles_russian, [String]
  def roles_russian
    object.roles.map { |role| I18n.t "role.#{role}", default: role }
  end
end
