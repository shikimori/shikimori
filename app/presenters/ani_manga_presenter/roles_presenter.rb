class AniMangaPresenter::RolesPresenter < BasePresenter
  # есть ли хоть какие-то роли?
  def any?
    entry.person_roles.any?
  end

  # авторы аниме
  def directors
    @directors ||= entry.person_roles.directors
        .where { people.name.not_eq(nil) }
        .all
        .select { |v| !(v.role.split(',') & ['Director', 'Original Creator', 'Story & Art', 'Story', 'Art']).empty? }
        .uniq_by { |v| v.person.name }
        .sort_by(&:role)
  end

  # персонажи аниме
  def main_characters
    @main_characters ||= entry.person_roles.main
        .includes(:character)
        .where { characters.name.not_eq(nil) }
        .all
        .uniq_by { |v| v.character.name }
        .sort_by { |v| v.character.name }
  end

  def characters
    @characters ||= begin
      main_ids = entry.person_roles.main.pluck(:character_id)

      entry.characters
          .includes(:seyu)
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
    @people ||= entry.person_roles.people
        .order("people.name")
        .select { |v| !v.person.nil? }
  end
end
