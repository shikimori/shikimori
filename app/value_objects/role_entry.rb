class RoleEntry < SimpleDelegator
  attr_reader :role

  def initialize entry, role
    super entry
    @role = role
  end

  def formatted_role
    (@role.present? ? translated_role(false) : '&nbsp;').html_safe
  end

  def formatted_roles
    (@role.present? ? translated_role(true) : '&nbsp;').html_safe
  end

private
  def translated_role is_full
    roles = @role
      .split(/, */)
      .map {|v| I18n.t "Role.#{v}" }
      .sort
      .join(', ')

    if roles.size > 1 && is_full
      roles
    else
      roles.first
    end
  end
end
