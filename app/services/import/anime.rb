class Import::Anime < Import::ImportBase
  SPECIAL_FIELDS = %i(
    genres studios related
  )

private

  # rubocop:disable MethodLength
  def assign_genres genres
    genres.each do |genre|
      db_genre = Repos::AnimeGenres.instance.all.find do |db_entry|
        db_entry.mal_id == genre[:id]
      end
      db_genre ||= Genre.create!(
        mal_id: genre[:id],
        name: genre[:name],
        kind: :anime
      )
      entry.genres << db_genre
    end
  end
  # rubocop:enable MethodLength

  def assign_studios studios
  end

  def assign_related related
  end

  def klass
    Anime
  end
end
