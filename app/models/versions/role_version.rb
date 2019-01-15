class Versions::RoleVersion < Version
  Actions = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:add, :remove)

  def antispam_enabled?
    false
  end

  def action
    Actions[item_diff['action']]
  end

  def role
    Types::User::Roles[item_diff['role']]
  end

  def apply_changes
    case action
      when Actions[:add] then add_role
      when Actions[:remove] then remove_role
    end
  end

  def rollback_changes
    case action
      when Actions[:add] then remove_role
      when Actions[:remove] then add_role
    end
  end

private

  def add_role
    item.update! roles: (item.roles.values + [role.to_s]).uniq
  end

  def remove_role
    item.update! roles: item.roles.values - [role.to_s]
  end
end
