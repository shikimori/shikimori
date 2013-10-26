class AddWorldArtFieldsToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :russian, :string
    add_column :animes, :world_art_id, :integer, :default => 0
    add_column :animes, :world_art_synonyms, :text
  end

  def self.down
    remove_column :animes, :world_art_synonyms
    remove_column :animes, :world_art_id
    remove_column :animes, :russian
  end
end
