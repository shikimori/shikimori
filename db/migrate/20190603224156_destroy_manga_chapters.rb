class DestroyMangaChapters < ActiveRecord::Migration[5.2]
  def up
    drop_table :manga_chapters
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
