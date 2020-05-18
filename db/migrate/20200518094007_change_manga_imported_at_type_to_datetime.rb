class ChangeMangaImportedAtTypeToDatetime < ActiveRecord::Migration[5.2]
  def up
    change_column :mangas, :imported_at, :datetime
  end

  def down
    change_column :mangas, :imported_at, :date
  end
end
