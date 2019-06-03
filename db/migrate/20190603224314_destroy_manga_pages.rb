class DestroyMangaPages < ActiveRecord::Migration[5.2]
  def up
    drop_table :manga_pages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
