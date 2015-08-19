class SetAnimeAndMangaScoreNotNull < ActiveRecord::Migration
  def up
    change_column :animes, :score, :decimal, null: false, default: 0
    change_column :mangas, :score, :decimal, null: false, default: 0
  end

  def down
    change_column :animes, :score, :decimal, null: true
    change_column :mangas, :score, :decimal, null: true
  end
end
