class AniMangaDecorator::RolesDecorator < BaseDecorator
  instance_cache :main_people, :main_characters, :supporting_characters, :people

  # есть ли хоть какие-то роли?
  def any?
    object.person_roles.any?
  end

  # главные участники проекта
  def main_people
    object
      .person_roles.directors
      .references(:people)
      .where.not(people: { name: nil })
        .select { |v| !(v.role.split(',') & ['Director', 'Original Creator', 'Story & Art', 'Story', 'Art']).empty? }
        .uniq { |v| v.person.name }
        .map {|v| RoleEntry.new v.person, v.role }
        .sort_by(&:formatted_role)
  end

  # все участники проекта
  def people
    object
      .person_roles.people
      .map {|v| RoleEntry.new v.person, v.role }
      .sort_by(&:formatted_role)
  end

  # главные персонажи аниме
  def main_characters
    characters :main
  end

  # главные персонажи аниме
  def supporting_characters
    characters :supporting
  end

  def grouping_class
    if main_people.any? && main_characters.any?
      if main_characters.size <= 4 && main_people.size <= 4
        'four-characters'
      elsif main_characters.size <= 5 && main_people.size <= 3
        'five-characters'
      elsif main_characters.size <= 6 && main_people.size <= 2
        'six-characters'
      end
    end
  end

private
  def characters role
    object
      .person_roles.send(role)
      .includes(:character)
      .references(:character)
      .where.not(characters: { name: nil })
        .map(&:character)
        .uniq
        .sort_by(&:name)
  end
end
