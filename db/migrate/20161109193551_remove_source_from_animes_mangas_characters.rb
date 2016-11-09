class RemoveSourceFromAnimesMangasCharacters < ActiveRecord::Migration
  def change
    remove_column :animes, :source, :string
    remove_column :mangas, :source, :string
    remove_column :characters, :source, :string
  end
end
