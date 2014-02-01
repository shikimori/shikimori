class CharactersQuery < PeopleQuery
  def initialize(params)
    super params, Character
  end

  def fill_works(fetched_query)
    people_by_id = fill_by_id fetched_query

    roles = PersonRole.where(character_id: fetched_query.map(&:id))
        .where { anime_id.not_eq(0) | manga_id.not_eq(0) }
        .select([:character_id, :anime_id, :manga_id])
        .to_a

    anime_roles = roles.each_with_object({}) do |role, memo|
      (memo[role.anime_id] = memo[role.anime_id] || []) << people_by_id[role.character_id]
    end

    manga_roles = roles.each_with_object({}) do |role, memo|
      (memo[role.manga_id] = memo[role.manga_id] || []) << people_by_id[role.character_id]
    end

    works = Anime.where(id: anime_roles.keys) + Manga.where(id: manga_roles.keys)

    works.sort_by {|v| v.aired_on || v.released_on || DateTime.now - 99.years }.reverse.each do |entry|
      (entry.class == Anime ? anime_roles : manga_roles)[entry.id].each do |person|
        break if person.last_works.size >= WorksLimit
        person.last_works << entry
      end
    end

    works.sort_by {|v| v.score }.reverse.each do |entry|
      (entry.class == Anime ? anime_roles : manga_roles)[entry.id].each do |person|
        break if person.best_works.size >= WorksLimit
        person.best_works << entry
      end
    end

    fetched_query
  end

private
  # ключи, по которым будет вестись поиск
  def search_fields(term)
    if term.contains_cjkv?
      [:japanese]
    elsif term =~ /[А-я]/
      [:russian]
    else
      [:name]
    end
  end
end
