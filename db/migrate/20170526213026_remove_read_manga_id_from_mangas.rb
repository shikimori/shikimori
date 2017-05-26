class RemoveReadMangaIdFromMangas < ActiveRecord::Migration[5.0]
  def change
    remove_column :mangas, :read_manga_id, :string, limit: 255
  end
end
