class DropAniDbScoresAndWorldArtScoresFromAnimes < ActiveRecord::Migration[5.0]
  def change
    remove_column :animes, :ani_db_scores, :string, limit: 255
    remove_column :animes, :world_art_scores, :string, limit: 255
  end
end
