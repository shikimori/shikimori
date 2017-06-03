class DropSynonymsOldInAnimesAndMangas < ActiveRecord::Migration[5.0]
  def change
    remove_column :animes, :synonyms_old, :text
    remove_column :mangas, :synonyms_old, :text
  end
end
