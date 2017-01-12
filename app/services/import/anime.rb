class Import::Anime < Import::ImportBase
  SPECIAL_FIELDS = %i(
    image synopsis
    genres studios related recommendations characters
    external_links
  )
  IGNORED_FIELDS = %i(members favorites)

private

  def assign_synopsis synopsis
    super unless anidb_synopsis?
  end

  def assign_genres genres
    genres.each do |genre|
      db_genre = genres_repo.all.find do |db_entry|
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

  def assign_external_links external_links
    Import::ExternalLinks.call entry, external_links
  end

  def assign_characters data
    if data[:characters].any? || data[:staff].any?
      Import::PersonRoles.call entry, data[:characters], data[:staff]
    end
  end

  def anidb_synopsis?
    entry.external_links.any? do |external_link|
      external_link.source_anime_db? && external_link.imported_at.present?
    end
  end

  def genres_repo
    Repos::AnimeGenres.instance
  end
end
