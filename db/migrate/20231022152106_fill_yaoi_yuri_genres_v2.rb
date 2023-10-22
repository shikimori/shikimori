class FillYaoiYuriGenresV2 < ActiveRecord::Migration[7.0]
  def up
    [Anime, Manga].each do |klass|
      klass
        .where("genre_v2_ids && '{#{(GenreV2::EROTICA_IDS + GenreV2::HENTAI_IDS).join(',')}}'")
        .each do |db_entry|
          new_genre_ids = migrate_genres(
            db_entry.genres_v2,
            "#{klass}GenresV2Repository".constantize.instance
          )
          if new_genre_ids != db_entry.genres_v2.pluck(:id)
            puts "#{klass.name}##{db_entry.id} #{db_entry.genres_v2.pluck(:id).join(',')} => #{new_genre_ids.join(',')}"
            db_entry.update! genre_v2_ids: new_genre_ids
          end
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
