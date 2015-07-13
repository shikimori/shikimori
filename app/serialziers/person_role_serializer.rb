class PersonRoleSerializer < ActiveModel::Serializer
  attributes :roles, :roles_russian
  has_one :character, :person

  def roles
    object.role.split(/ *, */)
  end

  def roles_russian
    roles.map {|role| I18n.t "Role.#{role}", default: role }
  end
end
