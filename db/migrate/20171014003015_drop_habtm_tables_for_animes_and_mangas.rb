class DropHabtmTablesForAnimesAndMangas < ActiveRecord::Migration[5.1]
  def up
    drop_table :animes_genres
    drop_table :genres_mangas
    drop_table :animes_studios
    drop_table :mangas_publishers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
