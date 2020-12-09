class RemoveSourceFromDbEntries < ActiveRecord::Migration[5.2]
  def change
    remove_column :animes, :source, :string, limit: 255
    remove_column :mangas, :source, :string, limit: 255
    remove_column :characters, :source, :string, limit: 255
  end
end
