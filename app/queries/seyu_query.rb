class SeyuQuery < PeopleQuery
  def initialize params
    super params
    @kind = :seyu
  end

  def fill_works fetched_query
    people_by_id = fill_by_id fetched_query

    character_roles = PersonRole
      .where(person_id: people_by_id.keys)
      .where(role: Person::SeyuRoles)
      .where.not(character_id: 0)
      .select([:person_id, :character_id])
      .to_a

    anime_roles = PersonRole
      .where(character_id: character_roles.map(&:character_id))
      .where.not(anime_id: 0)
      .select([:character_id, :anime_id])
      .to_a

    anime_characters = anime_roles.each_with_object({}) do |role,memo|
      (memo[role.anime_id] = memo[role.anime_id] || []) << role.character_id
    end
    #character_animes = anime_roles.each_with_object({}) do |role,memo|
      #(memo[role.character_id] = memo[role.character_id] || []) << role.anime_id
    #end

    person_characters = character_roles.each_with_object({}) do |role,memo|
      (memo[role.person_id] = memo[role.person_id] || []) << role.character_id
    end
    character_people = character_roles.each_with_object({}) do |role,memo|
      (memo[role.character_id] = memo[role.character_id] || []) << role.person_id
    end

    person_animes = people_by_id.each_with_object({}) do |(person_id,person),memo|
      memo[person_id] = OrderedSet.new
    end
    person_characters = people_by_id.each_with_object({}) do |(person_id,person),memo|
      memo[person_id] = OrderedSet.new
    end

    animes = Anime
      .where(id: anime_roles.map(&:anime_id))
      .order(score: :desc)
      .to_a
    characters = Character
      .where(id: character_roles.map(&:character_id))
      .each_with_object({}) do |character,memo|
        memo[character.id] = character
      end

    animes.each do |anime|
      anime_characters[anime.id].each do |character_id|
        character_people[character_id].each do |person_id|
          person_characters[person_id] << characters[character_id] if person_characters[person_id].size < WorksLimit
        end
      end
    end
    animes.sort_by {|v| v.aired_on || v.released_on || DateTime.now + 10.years }.reverse.each do |anime|
      anime_characters[anime.id].each do |character_id|
        character_people[character_id].each do |person_id|
          person_animes[person_id] << anime if person_animes[person_id].size < WorksLimit
        end
      end
    end

    fetched_query.each do |person|
      person.last_works = person_animes[person.id]
      person.best_works = person_characters[person.id]
    end
  end
end
