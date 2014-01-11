module PeopleHelper
  def format_person_role role, options = { full: false }
    roles = role.split(/, */)
    if roles.size > 1
      if options[:full]
        roles.map {|v| I18n.t "Role.#{v}" }.sort.join(', ')
      else
        "#{I18n.t "Role.#{roles.first}"} (+)"
      end
    else
      I18n.t "Role.#{roles.first}"
    end
  end
end
