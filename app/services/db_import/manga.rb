class DbImport::Manga < DbImport::Anime
  SPECIAL_FIELDS = DbImport::Anime::SPECIAL_FIELDS + %i(publishers) - %i(
    studios
  )

private

  def assign_genres genres
    entry.genres = []
    genres.each { |genre| assign_genre genre }
  end

  def assign_genre genre
    db_genre =
      begin
        Repos::MangaGenres.instance.find_mal_id genre[:id]
      rescue ActiveRecord::RecordNotFound
        Genre.create! mal_id: genre[:id], name: genre[:name], kind: :manga
      end

    entry.genres << db_genre
  end

  def assign_publishers publishers
    entry.publishers = []
    publishers.each { |publisher| assign_publisher publisher }
  end

  def assign_publisher publisher
    db_publisher =
      begin
        Repos::Publishers.instance.find publisher[:id]
      rescue ActiveRecord::RecordNotFound
        Publisher.create! id: publisher[:id], name: publisher[:name]
      end

    entry.publishers << db_publisher
  end
end
