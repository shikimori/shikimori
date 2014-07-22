class AniMangaPresenter::RolesPresenter < BasePresenter
  # есть ли хоть какие-то роли?
  def any?
    entry.person_roles.any?
  end

  # авторы аниме
  def directors
    @directors ||= entry
      .person_roles
      .directors
      .references(:people)
      .where.not(people: { name: nil })
      .select { |v| !(v.role.split(',') & ['Director', 'Original Creator', 'Story & Art', 'Story', 'Art']).empty? }
      .uniq { |v| v.person.name }
      .sort_by(&:role)
  end

  # персонажи аниме
  def main_characters
    @main_characters ||= entry
      .person_roles
      .main
      .includes(:character)
      .references(:character)
      .where.not(characters: { name: nil })
      .uniq { |v| v.character.name }
      .sort_by { |v| v.character.name }
  end

  def characters
    @characters ||= begin
      main_ids = entry.person_roles.main.pluck(:character_id)

      entry
          .characters
          .includes(:seyu)
          .select {|v| v.name.present? }
          .sort_by(&:name)
          .map do |v|
        {
          role: main_ids.include?(v.id) ? 'Main' : 'Supporting',
          character: v,
          character_id: v.id
        }
      end
    end
  end

  def people
    @people ||= entry
      .person_roles
      .people
      .order("people.name")
      .select { |v| !v.person.nil? }
  end

  def grouping_class
    if main_characters.size <= 4 && directors.size <= 4
      'four-characters'
    elsif main_characters.size <= 5 && directors.size <= 3
      'five-characters'
    elsif main_characters.size <= 6 && directors.size <= 2
      'six-characters'
    end
  end
end
