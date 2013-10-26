class AddNotNullToAnimeEpisodes < ActiveRecord::Migration
  def self.up
    change_column :animes, :episodes, :integer, :null => false, :default => 0
  end

  def self.down
  end
end
