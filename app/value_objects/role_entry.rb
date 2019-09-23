class RoleEntry < SimpleDelegator
  attr_reader :roles

  # to fix work of TopicSerializer
  def self.model_name
    ActiveModel::Name.new(self)
  end

  def initialize entry, roles
    super entry
    @roles = roles
  end

  def formatted_role
    (@roles.present? ? translated_roles(is_full: false) : '&nbsp;').html_safe
  end

  def formatted_roles
    (@roles.present? ? translated_roles(is_full: true) : '&nbsp;').html_safe
  end

private

  def translated_roles is_full:
    @roles
      .map { |role| I18n.t "role.#{role}", default: role }
      .sort
      .take(is_full ? 10 : 1)
      .join(', ')
  end
end
