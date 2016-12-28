class Import::Anime < Import::ImportBase
  SPECIAL_FIELDS = %i(
    genres studios related recommendations characters
  )
  # characters image synopsis
  IGNORED_FIELDS = %i(members favorites synopsis external_links)

private

  def assign_genres genres
    genres.each do |genre|
      db_genre = Repos::AnimeGenres.instance.all.find do |db_entry|
        db_entry.mal_id == genre[:id]
      end
      db_genre ||= Genre.create!(
        mal_id: genre[:id], name: genre[:name], kind: :anime
      )
      entry.genres << db_genre
    end
  end

  def assign_studios studios
    studios.each do |studio|
      db_studio = Repos::Studios.instance.all.find do |db_entry|
        db_entry.id == studio[:id]
      end
      db_studio ||= Studio.create!(
        id: studio[:id],
        name: studio[:name]
      )
      entry.studios << db_studio
    end
  end

  def assign_related related
    Import::Related.call entry, related
  end

  def assign_recommendations similarities
    Import::Similarities.call entry, similarities
  end

  def assign_characters data
    if data[:characters].any? || data[:staff].any?
      Import::PersonRoles.call entry, data[:characters], data[:staff]
    end
  end

  def klass
    Anime
  end
end
