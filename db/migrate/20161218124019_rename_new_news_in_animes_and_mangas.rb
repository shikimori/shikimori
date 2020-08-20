class RenameNewNewsInAnimesAndMangas < ActiveRecord::Migration[5.2]
  def change
    rename_column :animes, :english_new, :english
    rename_column :animes, :japanese_new, :japanese
    rename_column :mangas, :english_new, :english
    rename_column :mangas, :japanese_new, :japanese
  end
end
