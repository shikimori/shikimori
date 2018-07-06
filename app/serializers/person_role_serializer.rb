class PersonRoleSerializer < ActiveModel::Serializer
  attributes :roles, :roles_russian
  has_one :character
  has_one :person

  def roles
    object.roles
  end

  def roles_russian
    roles.map { |role| I18n.t "role.#{role}", default: role }
  end
end
