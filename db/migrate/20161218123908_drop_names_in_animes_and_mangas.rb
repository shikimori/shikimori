class DropNamesInAnimesAndMangas < ActiveRecord::Migration[5.2]
  def change
    remove_column :animes, :english, :string
    remove_column :animes, :japanese, :string
    remove_column :mangas, :english, :string
    remove_column :mangas, :japanese, :string
  end
end
