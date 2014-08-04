class RoleEntry < SimpleDelegator
  attr_reader :role

  def initialize person, role
    super person
    @role = role
  end
end
