class DropMalScoresFromAnimesAndMangas < ActiveRecord::Migration[5.0]
  def change
    remove_column :animes, :mal_scores, :string, limit: 255
    remove_column :mangas, :mal_scores, :string, limit: 255
  end
end
