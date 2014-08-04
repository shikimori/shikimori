class AniMangaDecorator::RolesDecorator < BaseDecorator
  instance_cache :main_people, :main_characters, :supporting_characters, :people

  # есть ли хоть какие-то роли?
  def any?
    object.person_roles.any?
  end

  # авторы аниме
  def main_people
    object
      .person_roles
      .directors
      .references(:people)
      .where.not(people: { name: nil })
      .select { |v| !(v.role.split(',') & ['Director', 'Original Creator', 'Story & Art', 'Story', 'Art']).empty? }
      .uniq { |v| v.person.name }
      .sort_by(&:role)
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
    if main_characters.size <= 4 && main_people.size <= 4
      'four-characters'
    elsif main_characters.size <= 5 && main_people.size <= 3
      'five-characters'
    elsif main_characters.size <= 6 && main_people.size <= 2
      'six-characters'
    end
  end

  def person_roles
    object.roles.people
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
  #def characters
    #main_ids = object.person_roles.main.pluck(:character_id)

    #object
        #.characters
        #.includes(:seyu)
        #.select {|v| v.name.present? }
        #.sort_by(&:name)
        #.map do |v|
      #{
        #role: main_ids.include?(v.id) ? 'Main' : 'Supporting',
        #character: v,
        #character_id: v.id
      #}
    #end
  #end

  def people
    object
      .person_roles
      .people
      .order("people.name")
      .select { |v| !v.person.nil? }
  end
end
