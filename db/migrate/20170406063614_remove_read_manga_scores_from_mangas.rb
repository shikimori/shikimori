class RemoveReadMangaScoresFromMangas < ActiveRecord::Migration[5.0]
  def change
    remove_column :mangas, :read_manga_scores, :decimal,
      precision: 8,
      scale: 2,
      default: '0.0'
  end
end
