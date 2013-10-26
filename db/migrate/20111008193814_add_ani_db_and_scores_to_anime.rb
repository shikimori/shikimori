class AddAniDbAndScoresToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :ani_db_id, :integer, :default => 0
    add_column :animes, :mal_scores, :string
    add_column :animes, :ani_db_scores, :string
    add_column :animes, :world_art_scores, :string
  end

  def self.down
    remove_column :animes, :world_art_scores
    remove_column :animes, :ani_db_scores
    remove_column :animes, :mal_scores
    remove_column :animes, :ani_db_id
  end
end
