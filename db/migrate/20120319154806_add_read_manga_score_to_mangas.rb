class AddReadMangaScoreToMangas < ActiveRecord::Migration
  def self.up
    add_column :mangas, :read_manga_scores, :decimal, :default => 0, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :mangas, :read_manga_scores
  end
end
