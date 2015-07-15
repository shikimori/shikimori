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
    @role
      .split(/, */)
      .map {|role| I18n.t "role.#{role}", default: role }
      .sort
      .take(is_full ? 10 : 1)
      .join(', ')
  end
end
