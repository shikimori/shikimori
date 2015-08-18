class FixAnimeAndMangaScores < ActiveRecord::Migration
  def change
    change_column :animes, :score, :decimal, null: false, default: 0
    change_column :mangas, :score, :decimal, null: false, default: 0
  end
end
