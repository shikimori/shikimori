class SetAnimeAndMangaScoreNotNull < ActiveRecord::Migration
  def change
    change_column :animes, :score, :integer, null: false, default: 0
    change_column :mangas, :score, :integer, null: false, default: 0
  end
end
