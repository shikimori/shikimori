class FillYaoiYuriGenresV2 < ActiveRecord::Migration[7.0]
  def up
    [Anime, Manga].each do |klass|
      klass
        .where("genre_v2_ids && '{#{GenreV2::CENSORED_IDS.join(',')}}'")
        .each do |db_entry|
          puts "#{klass.name}##{db_entry.id}"
          db_entry.update!(
            genre_v2_ids: migrate_genres(
              db_entry.genres_v2,
              "#{klass}GenresV2Repository".constantize.instance
            )
          )
        end
    end
  end

private

  def migrate_genres genres, genres_repository
    cleaned_genre_ids = genres
      .reject do |v|
        v.name.in?(DbImport::Anime::LGBT_GENRES.values) || v.name.in?(DbImport::Anime::CENSORED_GENRES)
      end
      .pluck(:id)

    if genres.any? { |v| v.name == DbImport::Anime::LGBT_GENRES[:yaoi] }
      return cleaned_genre_ids + [genres_repository.by_name('Yaoi').id]
    elsif genres.any? { |v| v.name == DbImport::Anime::LGBT_GENRES[:yuri] }
      return cleaned_genre_ids + [genres_repository.by_name('Yuri').id]
    end

    genres.pluck :id
  end
end
