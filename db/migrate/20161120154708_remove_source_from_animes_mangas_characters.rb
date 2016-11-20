class RemoveSourceFromAnimesMangasCharacters < ActiveRecord::Migration
  def change
    remove_column :animes, :source
    remove_column :mangas, :source
    remove_column :characters, :source
  end
end
