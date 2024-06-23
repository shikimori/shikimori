class MigrateSomeMangaGenres < ActiveRecord::Migration[7.0]
  def up
    return unless Rails.env.production?

    MigrateGenreV2Ids.new(Manga).migrate genre_v2: GenreV2.find(59), to_id: 602
    MigrateGenreV2Ids.new(Manga).migrate genre_v2: GenreV2.find(540), to_id: 601
  end

  def down
    return unless Rails.env.production?

    MigrateGenreV2Ids.new(Manga).migrate genre_v2: GenreV2.find(602), to_id: 59
    MigrateGenreV2Ids.new(Manga).migrate genre_v2: GenreV2.find(601), to_id: 540
  end
end
