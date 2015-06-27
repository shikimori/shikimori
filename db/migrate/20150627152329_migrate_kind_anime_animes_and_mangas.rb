class MigrateKindAnimeAnimesAndMangas < ActiveRecord::Migration
  def up
    Anime.connection.execute('update animes set kind=lower(kind)')
    Manga.connection.execute("update mangas set kind=lower(replace(replace(kind, '-', '_'), ' ', '_'))")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
