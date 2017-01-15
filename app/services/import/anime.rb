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
    entry.genres = []
    genres.each { |genre| assign_genre genre }
  end

  def assign_genre genre
    db_genre =
      begin
        Repos::AnimeGenres.instance.find genre[:id]
      rescue ActiveRecord::RecordNotFound
        Genre.create! mal_id: genre[:id], name: genre[:name], kind: :anime
      end

    entry.genres << db_genre
  end

  def assign_studios studios
    entry.studios = []
    studios.each { |studio| assign_studio studio }
  end

  def assign_studio studio
    db_studio =
      begin
        Repos::Studios.instance.find studio[:id]
      rescue ActiveRecord::RecordNotFound
        Studio.create! id: studio[:id], name: studio[:name]
      end

    entry.studios << db_studio
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
end
