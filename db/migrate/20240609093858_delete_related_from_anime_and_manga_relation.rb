class DeleteRelatedFromAnimeAndMangaRelation < ActiveRecord::Migration[7.0]
  def up
    remove_column :related_animes, :relation
    remove_column :related_mangas, :relation
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
