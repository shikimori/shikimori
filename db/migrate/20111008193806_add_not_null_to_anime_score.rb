class AddNotNullToAnimeScore < ActiveRecord::Migration
  def self.up
    change_column :animes, :score, :float, :null => false, :default => 0
  end

  def self.down
  end
end
