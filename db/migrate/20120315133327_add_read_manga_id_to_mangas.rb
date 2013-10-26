class AddReadMangaIdToMangas < ActiveRecord::Migration
  def self.up
    add_column :mangas, :read_manga_id, :string
  end

  def self.down
    remove_column :mangas, :read_manga_id
  end
end
