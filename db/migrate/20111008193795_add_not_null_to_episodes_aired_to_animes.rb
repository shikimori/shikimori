class AddNotNullToEpisodesAiredToAnimes < ActiveRecord::Migration
  def self.up
    change_column :animes, :episodes_aired, :integer, :null => false, :default => 0
  end

  def self.down
  end
end
