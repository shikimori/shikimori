class RolesQuery < BaseDecorator
  prepend ActiveCacher.instance
  instance_cache :main_people, :main_characters, :supporting_characters, :people

  IMPORTANT_ROLES = PersonRole::DIRECTOR_ROLES

  pattr_initialize :entry

  # есть ли хоть какие-то роли?
  def any?
    entry.person_roles.any?
  end

  def displayed_people
    main_people.presence || people.take(2)
  end

  def main_people
    entry
      .person_roles.directors
      .references(:people)
      .where.not(people: { name: nil })
        .reject { |v| (v.roles & IMPORTANT_ROLES).empty? }
        .uniq { |v| v.person.name }
        .map { |v| RoleEntry.new v.person, v.roles }
        .sort_by(&:formatted_role)
  end

  # все участники проекта
  def people
    entry
      .person_roles.people
      .map { |v| RoleEntry.new v.person, v.roles }
      .sort_by do |v|
        [-(v.roles & IMPORTANT_ROLES).size, v.formatted_role]
      end
  end

  def main_characters
    characters :main
  end

  def supporting_characters
    characters :supporting
  end

private

  def characters role
    entry
      .person_roles.send(role)
      .includes(:character)
      .references(:character)
      .where.not(characters: { name: nil })
        .map(&:character)
        .uniq
        .sort_by(&:name)
  end
end
